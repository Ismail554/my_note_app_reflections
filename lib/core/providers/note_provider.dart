import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Reflections/core/services/note_service.dart';
import 'package:Reflections/shared/models/note_model.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  List<NoteModel> _archivedNotes = [];
  bool _isLoading = false;
  int _selectedNavIndex = 0;
  int _selectedTasksTabIndex = 0;

  List<String> _folders = ['Reflections'];
  String _selectedFolder = 'All';

  StreamSubscription<List<NoteModel>>? _notesSubscription;
  StreamSubscription<List<NoteModel>>? _archivedSubscription;
  StreamSubscription<User?>? _authSubscription;

  NoteProvider() {
    _initStorage();
    _authSubscription = FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        _notes.clear();
        _archivedNotes.clear();
        _folders = ['Reflections'];
        _selectedFolder = 'All';
        _cancelSubscriptions();
        notifyListeners();
      } else {
        if (_notes.isEmpty && _notesSubscription == null) {
          _initStorage();
        }
      }
    });
  }

  List<NoteModel> get notes => _notes;
  List<NoteModel> get archivedNotes => _archivedNotes;
  bool get isLoading => _isLoading;
  int get selectedNavIndex => _selectedNavIndex;
  int get selectedTasksTabIndex => _selectedTasksTabIndex;
  List<String> get folders => _folders;
  String get selectedFolder => _selectedFolder;

  List<NoteModel> get filteredNotes {
    final list = _selectedFolder == 'All'
        ? List<NoteModel>.from(_notes)
        : _notes.where((n) => n.category == _selectedFolder).toList();

    list.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  void _initStorage() {
    if (FirebaseAuth.instance.currentUser == null) return;
    _cancelSubscriptions();

    _isLoading = true;
    notifyListeners();

    _notesSubscription = NoteService.instance.getNotesStream().listen((notesList) {
      _notes = notesList;
      _updateFoldersFromNotes();
      _isLoading = false;
      notifyListeners();
    });

    _archivedSubscription = NoteService.instance.getArchivedNotesStream().listen((archivedList) {
      _archivedNotes = archivedList;
      notifyListeners();
    });
  }

  void _updateFoldersFromNotes() {
    final uniqueCategories = _notes
        .map((n) => n.category)
        .where((c) => c.isNotEmpty && c != 'All')
        .toSet()
        .toList();

    if (!uniqueCategories.contains('Reflections')) {
      uniqueCategories.add('Reflections');
    }

    for (var f in _folders) {
      if (!uniqueCategories.contains(f)) {
        uniqueCategories.add(f);
      }
    }

    uniqueCategories.sort();
    _folders = uniqueCategories;
  }

  void selectFolder(String folderName) {
    _selectedFolder = folderName;
    if (_selectedNavIndex != 0) {
      _selectedNavIndex = 0;
    }
    notifyListeners();
  }

  void createFolder(String name) {
    final trimName = name.trim();
    if (trimName.isEmpty || trimName.toLowerCase() == 'all') return;

    if (!_folders.contains(trimName)) {
      _folders.add(trimName);
      _folders.sort();
    }
    selectFolder(trimName);
  }

  void changeNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void setSelectedTasksTabIndex(int index) {
    if (_selectedTasksTabIndex == index) return;
    _selectedTasksTabIndex = index;
    notifyListeners();
  }

  Future<String> addNote(NoteModel note) async {
    final noteWithUser = note.copyWith(
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
    return await NoteService.instance.addNote(noteWithUser);
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    await NoteService.instance.updateNote(updatedNote);
  }

  Future<List<Map<String, dynamic>>> getNoteVersions(String noteId) async {
    return await NoteService.instance.getNoteVersions(noteId);
  }

  Future<void> archiveNote(String id, bool isArchived) async {
    await NoteService.instance.archiveNote(id, isArchived);
  }

  Future<void> deletePermanently(String id) async {
    await NoteService.instance.deletePermanently(id);
  }

  void _cancelSubscriptions() {
    _notesSubscription?.cancel();
    _notesSubscription = null;
    _archivedSubscription?.cancel();
    _archivedSubscription = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _authSubscription?.cancel();
    super.dispose();
  }
}
