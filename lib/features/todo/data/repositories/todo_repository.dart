import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/core/database/database_helper.dart';
import 'package:Reflections/features/todo/data/models/todo_model.dart';

class TodoRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // ─── Read ──────────────────────────────────────────────────────────────

  Future<List<TodoModel>> getTodos() async {
    final currentUid = uid;
    if (currentUid == null) return [];

    final rows = await _db.queryAll(
      'todos',
      where: 'user_id = ?',
      whereArgs: [currentUid],
    );

    final todos = rows.map((r) => TodoModel.fromSqlite(r)).toList();

    // Sort: uncompleted first, then by priority, then newest first
    todos.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priorityWeight != b.priorityWeight) {
        return b.priorityWeight.compareTo(a.priorityWeight);
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return todos;
  }

  /// Get todos completed between two dates (for analytics)
  Future<List<TodoModel>> getCompletedBetween(DateTime start, DateTime end) async {
    final currentUid = uid;
    if (currentUid == null) return [];

    final rows = await _db.rawQuery('''
      SELECT * FROM todos
      WHERE user_id = ? AND is_completed = 1
        AND completed_at BETWEEN ? AND ?
      ORDER BY completed_at ASC
    ''', [currentUid, start.toIso8601String(), end.toIso8601String()]);

    return rows.map((r) => TodoModel.fromSqlite(r)).toList();
  }

  /// Count completed todos per day in a range
  Future<Map<String, int>> getCompletionCountsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final currentUid = uid;
    if (currentUid == null) return {};

    final startStr = start.toIso8601String();
    final endStr = end.toIso8601String();

    final rows = await _db.rawQuery('''
      SELECT DATE(completed_at) as day, COUNT(*) as cnt
      FROM todos
      WHERE user_id = ? AND is_completed = 1
        AND completed_at BETWEEN ? AND ?
      GROUP BY DATE(completed_at)
      ORDER BY day ASC
    ''', [currentUid, startStr, endStr]);

    final map = <String, int>{};
    for (final row in rows) {
      final day = row['day'] as String?;
      if (day != null) {
        map[day] = row['cnt'] as int;
      }
    }
    return map;
  }

  // ─── Write ─────────────────────────────────────────────────────────────

  Future<int> addTodo(TodoModel todo) async {
    return await _db.insert('todos', todo.toSqlite());
  }

  Future<void> updateTodo(TodoModel todo) async {
    if (todo.id == null) return;
    await _db.update(
      'todos',
      todo.toSqlite(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(int id) async {
    await _db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
