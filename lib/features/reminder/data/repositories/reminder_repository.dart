import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/reminder/data/models/reminder_model.dart';

class ReminderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _remindersRef {
    final currentUid = uid;
    if (currentUid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(currentUid).collection('reminders');
  }

  Stream<List<ReminderModel>> getRemindersStream() {
    return _remindersRef.snapshots().map((snapshot) {
      final reminders = snapshot.docs
          .map((doc) => ReminderModel.fromMap(doc.data(), doc.id))
          .toList();
      reminders.sort((a, b) => a.triggerDateTime.compareTo(b.triggerDateTime));
      return reminders;
    });
  }

  Future<void> addReminder(ReminderModel reminder) async {
    await _remindersRef.add(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _remindersRef.doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _remindersRef.doc(id).delete();
  }
}
