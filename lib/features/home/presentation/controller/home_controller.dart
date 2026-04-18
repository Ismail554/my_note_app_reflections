import 'package:get/get.dart';
import 'package:Reflections/core/services/note_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';
import 'package:Reflections/shared/models/note_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedNavIndex = 0.obs;

  // Folder State
  final RxList<String> folders = <String>['Reflections'].obs;
  final RxString selectedFolder = 'All'.obs;

  // Derived filtered notes
  List<NoteModel> get filteredNotes {
    if (selectedFolder.value == 'All') return notes;
    return notes.where((n) => n.category == selectedFolder.value).toList();
  }

  @override
  void onInit() {
    super.onInit();

    // Initial load
    _initStorage();

    // Listen to Auth changes
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        notes.clear();
        folders.value = ['Reflections'];
        selectedFolder.value = 'All';
      } else {
        if (notes.isEmpty) {
          _initStorage();
        }
      }
    });
  }

  void _initStorage() {
    if (FirebaseAuth.instance.currentUser == null) return;

    notes.bindStream(NoteService.to.getNotesStream());

    // Listen to notes changes
    ever(notes, (_) => _updateFoldersFromNotes());
  }

  void _updateFoldersFromNotes() {
    final uniqueCategories = notes
        .map((n) => n.category)
        .where((c) => c.isNotEmpty && c != 'All')
        .toSet()
        .toList();

    if (!uniqueCategories.contains('Reflections')) {
      uniqueCategories.add('Reflections');
    }

    for (var f in folders) {
      if (!uniqueCategories.contains(f)) {
        uniqueCategories.add(f);
      }
    }

    uniqueCategories.sort();
    folders.value = uniqueCategories;
  }

  void selectFolder(String folderName) {
    selectedFolder.value = folderName;
    if (selectedNavIndex.value != 0) {
      changeNavIndex(0);
    }
  }

  void createFolder(String name) {
    final trimName = name.trim();
    if (trimName.isEmpty || trimName.toLowerCase() == 'all') return;

    if (!folders.contains(trimName)) {
      folders.add(trimName);
      folders.sort();
    }
    selectFolder(trimName);
  }

  void navigateToAddNote() {
    AppNavigator.goToAddNote();
  }

  void navigateToEditNote(NoteModel note) {
    AppNavigator.goToAddNote(note: note);
  }

  Future<void> addNote(NoteModel note) async {
    try {
      final noteWithUser = note.copyWith(
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
      await NoteService.to.addNote(noteWithUser);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save note');
    }
  }

  Future<void> updateNote(NoteModel updatedNote) async {
    try {
      await NoteService.to.updateNote(updatedNote);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note');
    }
  }

  Future<void> archiveNote(String id) async {
    try {
      await NoteService.to.archiveNote(id, true);
    } catch (e) {
      Get.snackbar('Error', 'Failed to archive note');
    }
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
  }
}
