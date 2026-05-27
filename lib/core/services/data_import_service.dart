import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Reflections/core/database/database_helper.dart';

/// Imports data from a JSON backup file into SQLite and Firestore.
class DataImportService {
  DataImportService._();

  /// Import data from a JSON file path. Returns error message or null on success.
  static Future<String?> importData(String filePath) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 'Not logged in';

      final file = File(filePath);
      if (!await file.exists()) return 'File not found';

      final jsonStr = await file.readAsString();
      final data = json.decode(jsonStr) as Map<String, dynamic>;

      final db = DatabaseHelper.instance;
      final sqliteDb = await db.database;

      // ─── Import Habits ─────────────────────────────────────────────────
      final habits = data['habits'] as List<dynamic>? ?? [];
      for (final h in habits) {
        final map = Map<String, dynamic>.from(h);
        final completedDays = (map.remove('completedDays') as List<dynamic>?) ?? [];

        // Override user_id to current user
        map['user_id'] = uid;
        map.remove('id'); // Let SQLite auto-generate

        final habitId = await sqliteDb.insert('habits', map);

        // Insert completions
        final batch = sqliteDb.batch();
        for (final day in completedDays) {
          batch.insert('habit_completions', {
            'habit_id': habitId,
            'completed_date': day.toString(),
          });
        }
        await batch.commit(noResult: true);
      }

      // ─── Import Todos ──────────────────────────────────────────────────
      final todos = data['todos'] as List<dynamic>? ?? [];
      for (final t in todos) {
        final map = Map<String, dynamic>.from(t);
        map['user_id'] = uid;
        map.remove('id');
        await sqliteDb.insert('todos', map);
      }

      // ─── Import Reminders ──────────────────────────────────────────────
      final reminders = data['reminders'] as List<dynamic>? ?? [];
      for (final r in reminders) {
        final map = Map<String, dynamic>.from(r);
        map['user_id'] = uid;
        map.remove('id');
        await sqliteDb.insert('reminders', map);
      }

      // ─── Import Notes (to Firestore) ───────────────────────────────────
      final notes = data['notes'] as List<dynamic>? ?? [];
      final notesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes');

      for (final n in notes) {
        final map = Map<String, dynamic>.from(n);
        map['userId'] = uid;

        // Convert ISO date strings back to Timestamps
        for (final key in ['createdAt', 'updatedAt']) {
          if (map[key] is String) {
            final dt = DateTime.tryParse(map[key] as String);
            if (dt != null) map[key] = Timestamp.fromDate(dt);
          }
        }

        await notesRef.add(map);
      }

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }
}
