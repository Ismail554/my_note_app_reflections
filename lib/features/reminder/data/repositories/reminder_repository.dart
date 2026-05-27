import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/core/database/database_helper.dart';
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';

class ReminderRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  // ─── Read ──────────────────────────────────────────────────────────────

  Future<List<ReminderModel>> getReminders() async {
    final currentUid = uid;
    if (currentUid == null) return [];

    final rows = await _db.queryAll(
      'reminders',
      where: 'user_id = ?',
      whereArgs: [currentUid],
      orderBy: 'trigger_date_time ASC',
    );

    return rows.map((r) => ReminderModel.fromSqlite(r)).toList();
  }

  Future<List<ReminderModel>> getUpcoming({int limit = 3}) async {
    final currentUid = uid;
    if (currentUid == null) return [];

    final now = DateTime.now().toIso8601String();
    final rows = await _db.rawQuery('''
      SELECT * FROM reminders
      WHERE user_id = ? AND trigger_date_time > ?
      ORDER BY trigger_date_time ASC
      LIMIT ?
    ''', [currentUid, now, limit]);

    return rows.map((r) => ReminderModel.fromSqlite(r)).toList();
  }

  // ─── Write ─────────────────────────────────────────────────────────────

  Future<int> addReminder(ReminderModel reminder) async {
    return await _db.insert('reminders', reminder.toSqlite());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) return;
    await _db.update(
      'reminders',
      reminder.toSqlite(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(int id) async {
    await _db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
