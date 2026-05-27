import 'package:flutter/material.dart';
import 'package:Reflections/features/habit/data/repositories/habit_repository.dart';
import 'package:Reflections/features/todo/data/repositories/todo_repository.dart';

enum AnalyticsRange { daily, weekly, monthly }

class AnalyticsProvider extends ChangeNotifier {
  final HabitRepository _habitRepo = HabitRepository();
  final TodoRepository _todoRepo = TodoRepository();

  AnalyticsRange _range = AnalyticsRange.weekly;
  Map<String, int> _habitData = {};
  Map<String, int> _todoData = {};
  bool _isLoading = false;

  AnalyticsRange get range => _range;
  Map<String, int> get habitData => _habitData;
  Map<String, int> get todoData => _todoData;
  bool get isLoading => _isLoading;

  int get totalHabitCompletions => _habitData.values.fold(0, (a, b) => a + b);
  int get totalTodoCompletions => _todoData.values.fold(0, (a, b) => a + b);
  int get activeDays => _habitData.keys.toSet().union(_todoData.keys.toSet()).length;

  double get consistencyScore {
    final daysBack = _daysForRange;
    if (daysBack == 0) return 0;
    return (activeDays / daysBack * 100).clamp(0, 100);
  }

  int get _daysForRange {
    switch (_range) {
      case AnalyticsRange.daily:
        return 7;
      case AnalyticsRange.weekly:
        return 28;
      case AnalyticsRange.monthly:
        return 180;
    }
  }

  void setRange(AnalyticsRange r) {
    _range = r;
    notifyListeners();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final start = now.subtract(Duration(days: _daysForRange));

    try {
      _habitData = await _habitRepo.getCompletionCountsByDate(start, now);
      _todoData = await _todoRepo.getCompletionCountsByDate(start, now);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
