import 'package:get/get.dart';
import 'package:my_notes/features/home/presentation/controller/home_controller.dart';
import 'package:my_notes/shared/models/note_model.dart';

class SearchController extends GetxController {
  final RxString query = ''.obs;
  final RxList<NoteModel> results = <NoteModel>[].obs;
  final RxBool hasSearched = false.obs;

  void search(String value) {
    query.value = value;
    if (value.trim().isEmpty) {
      results.clear();
      hasSearched.value = false;
      return;
    }
    hasSearched.value = true;
    final homeController = Get.find<HomeController>();
    results.value = homeController.notes
        .where((note) =>
            note.title.toLowerCase().contains(value.toLowerCase()) ||
            note.description.toLowerCase().contains(value.toLowerCase()))
        .toList();
  }

  void clear() {
    query.value = '';
    results.clear();
    hasSearched.value = false;
  }
}
