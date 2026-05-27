import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';

class HabitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _habitsRef {
    final currentUid = uid;
    if (currentUid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(currentUid).collection('habits');
  }

  Stream<List<HabitModel>> getHabitsStream() {
    return _habitsRef.snapshots().map((snapshot) {
      final habits = snapshot.docs
          .map((doc) => HabitModel.fromMap(doc.data(), doc.id))
          .toList();
      habits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return habits;
    });
  }

  Future<void> addHabit(HabitModel habit) async {
    await _habitsRef.add(habit.toMap());
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _habitsRef.doc(habit.id).update(habit.toMap());
  }

  Future<void> deleteHabit(String id) async {
    await _habitsRef.doc(id).delete();
  }
}
