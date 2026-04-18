import 'package:get/get.dart';
import 'package:my_notes/core/services/auth_service.dart';
import 'package:my_notes/core/utils/app_navigator.dart';

class SettingsController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString email = ''.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool autoSaveEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.to.currentUser;
    if (user != null) {
      displayName.value = user.displayName ?? 'User';
      email.value = user.email ?? '';
    }
  }

  Future<void> logout() async {
    await AuthService.to.signOut();
    AppNavigator.goToLogin();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggleAutoSave(bool value) {
    autoSaveEnabled.value = value;
  }
}
