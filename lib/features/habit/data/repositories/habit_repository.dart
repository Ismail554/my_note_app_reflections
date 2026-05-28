import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Reflections/core/database/database_helper.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';

class HabitRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // ─── Read ──────────────────────────────────────────────────────────────

  Future<List<HabitModel>> getHabits() async {
    final currentUid = uid;
    if (currentUid == null) return [];

    final rows = await _db.queryAll(
      'habits',
      where: 'user_id = ?',
      whereArgs: [currentUid],
      orderBy: 'created_at DESC',
    );

    final habits = <HabitModel>[];
    for (final row in rows) {
      final habitId = row['id'] as int;
      final completions = await _getCompletionsForHabit(habitId);
      habits.add(HabitModel.fromSqlite(row, completedDays: completions));
    }
    return habits;
  }

  Future<List<String>> _getCompletionsForHabit(int habitId) async {
    final rows = await _db.queryAll(
      'habit_completions',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_date DESC',
    );
    return rows.map((r) => r['completed_date'] as String).toList();
  }

  /// Get all completions across all habits for a date range (for analytics)
  Future<Map<String, int>> getCompletionCountsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final currentUid = uid;
    if (currentUid == null) return {};

    final startStr = start.toIso8601String().substring(0, 10);
    final endStr = end.toIso8601String().substring(0, 10);

    final rows = await _db.rawQuery('''
      SELECT hc.completed_date, COUNT(*) as cnt
      FROM habit_completions hc
      INNER JOIN habits h ON h.id = hc.habit_id
      WHERE h.user_id = ? AND hc.completed_date BETWEEN ? AND ?
      GROUP BY hc.completed_date
      ORDER BY hc.completed_date ASC
    ''', [currentUid, startStr, endStr]);

    final map = <String, int>{};
    for (final row in rows) {
      map[row['completed_date'] as String] = row['cnt'] as int;
    }
    return map;
  }

  // ─── Write ─────────────────────────────────────────────────────────────

  Future<int> addHabit(HabitModel habit) async {
    return await _db.insert('habits', habit.toSqlite());
  }

  Future<void> updateHabit(HabitModel habit) async {
    if (habit.id == null) return;
    await _db.update(
      'habits',
      habit.toSqlite(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<void> deleteHabit(int id) async {
    // Completions cascade-delete via FK
    await _db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ─── Completions ───────────────────────────────────────────────────────

  Future<void> toggleCompletion(int habitId, String dateStr) async {
    final existing = await _db.queryAll(
      'habit_completions',
      where: 'habit_id = ? AND completed_date = ?',
      whereArgs: [habitId, dateStr],
    );

    if (existing.isNotEmpty) {
      await _db.delete(
        'habit_completions',
        where: 'habit_id = ? AND completed_date = ?',
        whereArgs: [habitId, dateStr],
      );
    } else {
      await _db.insert('habit_completions', {
        'habit_id': habitId,
        'completed_date': dateStr,
      });
    }
  }

  Future<void> setCompletionProgress(int habitId, String dateStr, int stage) async {
    final db = await _db.database;
    // Clear any existing binary or suffixed completions for this date
    await db.delete(
      'habit_completions',
      where: 'habit_id = ? AND (completed_date = ? OR completed_date LIKE ?)',
      whereArgs: [habitId, dateStr, '$dateStr:%'],
    );

    if (stage > 0) {
      final valueToSave = stage == 5 ? dateStr : '$dateStr:$stage';
      await db.insert('habit_completions', {
        'habit_id': habitId,
        'completed_date': valueToSave,
      });
    }
  }

  // ─── Bulk (for import) ─────────────────────────────────────────────────

  Future<void> insertBulkCompletions(int habitId, List<String> dates) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final date in dates) {
      batch.insert('habit_completions', {
        'habit_id': habitId,
        'completed_date': date,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }
}
