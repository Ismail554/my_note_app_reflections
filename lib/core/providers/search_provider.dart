import 'package:flutter/material.dart';
import 'package:Reflections/shared/models/note_model.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  List<NoteModel> _results = [];
  bool _hasSearched = false;

  String get query => _query;
  List<NoteModel> get results => _results;
  bool get hasSearched => _hasSearched;

  void search(String value, List<NoteModel> allNotes) {
    _query = value;
    if (value.trim().isEmpty) {
      _results.clear();
      _hasSearched = false;
      notifyListeners();
      return;
    }
    _hasSearched = true;
    _results = allNotes
        .where(
          (note) =>
              note.title.toLowerCase().contains(value.toLowerCase()) ||
              note.description.toLowerCase().contains(value.toLowerCase()),
        )
        .toList();
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results.clear();
    _hasSearched = false;
    notifyListeners();
  }
}
