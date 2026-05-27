import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/todo/data/models/todo_model.dart';
import 'package:Reflections/features/todo/data/repositories/todo_repository.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository = TodoRepository();
  List<TodoModel> _todos = [];
  bool _isLoading = false;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;

  // ─── Computed Getters ──────────────────────────────────────────────────

  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get uncompletedCount => _todos.where((t) => !t.isCompleted).length;
  double get progressRatio => _todos.isEmpty ? 0.0 : completedCount / _todos.length;

  List<TodoModel> get overdueTodos => _todos.where((t) => t.isOverdue).toList();

  List<TodoModel> get todayTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _todos.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return true; // No due date = show always
      return t.dueDate!.isBefore(tomorrow);
    }).toList();
  }

  // ─── Load / Refresh ────────────────────────────────────────────────────

  Future<void> loadTodos() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _todos = await _repository.getTodos();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async => await loadTodos();

  // ─── CRUD ──────────────────────────────────────────────────────────────

  Future<void> addTodo(String title, String priority, DateTime? dueDate) async {
    final currentUid = _repository.uid;
    if (currentUid == null) return;

    final newTodo = TodoModel(
      title: title.trim(),
      priority: priority,
      dueDate: dueDate,
      userId: currentUid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addTodo(newTodo);
    await loadTodos();
  }

  Future<void> toggleTodoStatus(TodoModel todo) async {
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      completedAt: !todo.isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTodo(updated);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _repository.deleteTodo(id);
    await loadTodos();
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _repository.updateTodo(todo);
    await loadTodos();
  }

  // ─── Analytics Data ────────────────────────────────────────────────────

  Future<Map<String, int>> getCompletionsByDate({int daysBack = 30}) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: daysBack));
    return await _repository.getCompletionCountsByDate(start, end);
  }
}
