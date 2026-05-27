import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/habit/data/models/habit_model.dart';
import 'package:Reflections/features/habit/data/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository _repository = HabitRepository();
  List<HabitModel> _habits = [];
  bool _isLoading = false;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;

  HabitProvider() {
    _initStream();
  }

  void _initStream() {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;

    _repository.getHabitsStream().listen(
      (list) {
        _habits = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addHabit(String name, String description, String? alarmTime) async {
    final uid = _repository.uid;
    if (uid == null) return;

    final newHabit = HabitModel(
      id: '',
      name: name.trim(),
      description: description.trim(),
      alarmTime: alarmTime,
      userId: uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addHabit(newHabit);
  }

  Future<void> toggleHabitDay(HabitModel habit, String dateStr) async {
    final toggledHabit = habit.toggleDay(dateStr);
    await _repository.updateHabit(toggledHabit);
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
  }
}
