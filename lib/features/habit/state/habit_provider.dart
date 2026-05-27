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

  // ─── Computed Getters ──────────────────────────────────────────────────

  int get currentStreak {
    if (_habits.isEmpty) return 0;
    // Overall streak = days in a row where at least 1 habit was completed
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final dateStr = checkDate.toIso8601String().substring(0, 10);
      final anyCompleted = _habits.any((h) => h.isCompletedOn(dateStr));
      if (anyCompleted) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (checkDate == today) {
        // Today not done yet, check yesterday
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  double get todayCompletionRate {
    if (_habits.isEmpty) return 0;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final completed = _habits.where((h) => h.isCompletedOn(todayStr)).length;
    return completed / _habits.length;
  }

  int get todayCompletedCount {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    return _habits.where((h) => h.isCompletedOn(todayStr)).length;
  }

  List<HabitModel> get todayHabits => _habits;

  // ─── Load / Refresh ────────────────────────────────────────────────────

  Future<void> loadHabits() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _repository.getHabits();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async => await loadHabits();

  // ─── CRUD ──────────────────────────────────────────────────────────────

  Future<void> addHabit({
    required String name,
    String description = '',
    String icon = '🎯',
    int color = 0xFFFF6B35,
    int targetDaysPerWeek = 7,
    String? alarmTime,
  }) async {
    final currentUid = _repository.uid;
    if (currentUid == null) return;

    final newHabit = HabitModel(
      name: name.trim(),
      description: description.trim(),
      icon: icon,
      color: color,
      targetDaysPerWeek: targetDaysPerWeek,
      alarmTime: alarmTime,
      userId: currentUid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addHabit(newHabit);
    await loadHabits();
  }

  Future<void> toggleHabitDay(HabitModel habit, String dateStr) async {
    if (habit.id == null) return;
    await _repository.toggleCompletion(habit.id!, dateStr);
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await _repository.deleteHabit(id);
    await loadHabits();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _repository.updateHabit(habit);
    await loadHabits();
  }

  // ─── Analytics Data ────────────────────────────────────────────────────

  /// Get completion counts per day for heatmap
  Future<Map<String, int>> getHeatmapData({int daysBack = 365}) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: daysBack));
    return await _repository.getCompletionCountsByDate(start, end);
  }
}
