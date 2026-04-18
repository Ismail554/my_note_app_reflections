import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:Reflections/shared/models/note_model.dart';

class NoteService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static NoteService get to => Get.find();

  String? get uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _notesRef {
    if (uid == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  /// Streams all non-archived notes for the current user
  Stream<List<NoteModel>> getNotesStream() {
    return _notesRef
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList();
          // Manual sorting if needed, or wait for index creation
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return notes;
        })
        .handleError((error) {
          Get.snackbar(
            'Sync Error',
            'Check your Firestore indexes: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  /// Streams all archived notes for the current user
  Stream<List<NoteModel>> getArchivedNotesStream() {
    return _notesRef
        .where('isArchived', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final notes = snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data(), doc.id))
              .toList();
          notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return notes;
        })
        .handleError((error) {
          Get.snackbar(
            'Sync Error',
            'Check your Firestore indexes: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
        });
  }

  Future<void> addNote(NoteModel note) async {
    await _notesRef.add(note.toMap());
  }

  Future<void> updateNote(NoteModel note) async {
    await _notesRef.doc(note.id).update(note.toMap());
  }

  Future<void> archiveNote(String id, bool isArchived) async {
    await _notesRef.doc(id).update({
      'isArchived': isArchived,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deletePermanently(String id) async {
    await _notesRef.doc(id).delete();
  }
}
