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

  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get uncompletedCount => _todos.where((t) => !t.isCompleted).length;
  double get progressRatio => _todos.isEmpty ? 0.0 : completedCount / _todos.length;

  TodoProvider() {
    _initStream();
  }

  void _initStream() {
    if (FirebaseAuth.instance.currentUser == null) return;
    _isLoading = true;

    _repository.getTodosStream().listen(
      (list) {
        _todos = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addTodo(String title, String priority, DateTime? dueDate) async {
    final uid = _repository.uid;
    if (uid == null) return;

    final newTodo = TodoModel(
      id: '',
      title: title.trim(),
      priority: priority,
      dueDate: dueDate,
      userId: uid,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.addTodo(newTodo);
  }

  Future<void> toggleTodoStatus(TodoModel todo) async {
    final updated = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTodo(updated);
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteTodo(id);
  }
}
