import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:Reflections/shared/models/note_model.dart';

class NoteService {
  static final NoteService instance = NoteService._internal();
  NoteService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static NoteService get to => instance;

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
          debugPrint('Sync Error: $error');
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
          debugPrint('Sync Error: $error');
        });
  }

  Future<String> addNote(NoteModel note) async {
    final docRef = note.id.isEmpty ? _notesRef.doc() : _notesRef.doc(note.id);
    final noteWithId = note.copyWith(id: docRef.id);
    await docRef.set(noteWithId.toMap());
    return docRef.id;
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      final currentDoc = await _notesRef.doc(note.id).get();
      if (currentDoc.exists) {
        final currentData = currentDoc.data();
        if (currentData != null) {
          final oldTitle = currentData['title'] as String? ?? '';
          final oldDescription = currentData['description'] as String? ?? '';
          if (oldTitle != note.title || oldDescription != note.description) {
            await addNoteVersion(note.id, oldTitle, oldDescription);
          }
        }
      }
    } catch (e) {
      debugPrint('Version auto-save error: $e');
    }
    await _notesRef.doc(note.id).update(note.toMap());
  }

  Future<void> addNoteVersion(String noteId, String title, String description) async {
    try {
      final versionsRef = _notesRef.doc(noteId).collection('versions');
      final latest = await versionsRef.orderBy('updatedAt', descending: true).limit(1).get();
      if (latest.docs.isNotEmpty) {
        final latestData = latest.docs.first.data();
        if (latestData['title'] == title && latestData['description'] == description) {
          return; // Duplicate
        }
      }
      await versionsRef.add({
        'title': title,
        'description': description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to save note version: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNoteVersions(String noteId) async {
    try {
      final snapshot = await _notesRef.doc(noteId).collection('versions').orderBy('updatedAt', descending: true).get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'title': doc.data()['title'] as String? ?? '',
        'description': doc.data()['description'] as String? ?? '',
        'updatedAt': (doc.data()['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      }).toList();
    } catch (e) {
      debugPrint('Failed to load note versions: $e');
      return [];
    }
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
