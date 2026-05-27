import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Reflections/features/todo/data/models/todo_model.dart';

class TodoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _todosRef {
    final currentUid = uid;
    if (currentUid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(currentUid).collection('todos');
  }

  Stream<List<TodoModel>> getTodosStream() {
    return _todosRef.snapshots().map((snapshot) {
      final todos = snapshot.docs
          .map((doc) => TodoModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort: uncompleted first, then by priority, then by createdAt descending
      todos.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        
        // Priority weight comparison
        final aWeight = _priorityWeight(a.priority);
        final bWeight = _priorityWeight(b.priority);
        if (aWeight != bWeight) {
          return bWeight.compareTo(aWeight); // Higher priority first
        }
        
        return b.createdAt.compareTo(a.createdAt);
      });
      return todos;
    });
  }

  int _priorityWeight(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    await _todosRef.add(todo.toMap());
  }

  Future<void> updateTodo(TodoModel todo) async {
    await _todosRef.doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String id) async {
    await _todosRef.doc(id).delete();
  }
}
