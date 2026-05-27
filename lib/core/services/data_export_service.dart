import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Reflections/core/database/database_helper.dart';

/// Exports all app data (habits + completions, todos, reminders from SQLite;
/// notes from Firestore) as a single JSON file.
class DataExportService {
  DataExportService._();

  static Future<String?> exportData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 'Not logged in';

      final db = DatabaseHelper.instance;

      // ─── SQLite data ───────────────────────────────────────────────────
      final habits = await db.queryAll('habits', where: 'user_id = ?', whereArgs: [uid]);
      final completions = await db.queryAll('habit_completions');
      final todos = await db.queryAll('todos', where: 'user_id = ?', whereArgs: [uid]);
      final reminders = await db.queryAll('reminders', where: 'user_id = ?', whereArgs: [uid]);

      // Match completions to habits
      final habitsWithCompletions = habits.map((h) {
        final id = h['id'] as int;
        final hCompletions = completions
            .where((c) => c['habit_id'] == id)
            .map((c) => c['completed_date'] as String)
            .toList();
        return {...h, 'completedDays': hCompletions};
      }).toList();

      // ─── Firestore notes ───────────────────────────────────────────────
      final notesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();

      final notes = notesSnapshot.docs.map((doc) {
        final data = doc.data();
        // Convert Timestamps to ISO strings for JSON
        return data.map((key, value) {
          if (value is Timestamp) return MapEntry(key, value.toDate().toIso8601String());
          return MapEntry(key, value);
        });
      }).toList();

      // ─── Build export JSON ─────────────────────────────────────────────
      final exportData = {
        'appVersion': '1.0.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': uid,
        'habits': habitsWithCompletions,
        'todos': todos,
        'reminders': reminders,
        'notes': notes,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);

      // ─── Save to temp file and share ───────────────────────────────────
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/reflections_backup.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Reflections App Backup',
        ),
      );

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }
}
