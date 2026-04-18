import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:my_notes/core/services/note_service.dart';
import 'package:my_notes/shared/models/note_model.dart';

class ArchiveController extends GetxController {
  
  final RxList<NoteModel> archivedNotes = <NoteModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initStorage();
    
    // logout
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user == null) {
        archivedNotes.clear();
      } else if (archivedNotes.isEmpty) {
        _initStorage();
      }
    });
  }

  void _initStorage() {
    if (FirebaseAuth.instance.currentUser == null) return;
    archivedNotes.bindStream(NoteService.to.getArchivedNotesStream());
  }


// unarchive note
  Future<void> unarchive(NoteModel note) async {
    try {
      await NoteService.to.archiveNote(note.id, false);
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore note');
    }
  }


// delete note
  Future<void> deletePermanently(String id) async {
    try {
      await NoteService.to.deletePermanently(id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note');
    }
  }
}
