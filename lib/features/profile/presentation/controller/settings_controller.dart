import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/services/user_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

class SettingsController extends GetxController {
  final RxString displayName = ''.obs;
  final RxString email = ''.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool autoSaveEnabled = true.obs;

  final RxString currentLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initLanguage();
  }

  void _initLanguage() {
    final locale = Get.locale ?? const Locale('en', 'US');
    if (locale.languageCode == 'es') {
      currentLanguage.value = 'Español';
    } else {
      currentLanguage.value = 'English';
    }
  }

  void changeLanguage(String langCode) {
    if (langCode == 'es') {
      Get.updateLocale(const Locale('es', 'ES'));
      currentLanguage.value = 'Español';
    } else {
      Get.updateLocale(const Locale('en', 'US'));
      currentLanguage.value = 'English';
    }
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

  Future<bool> updateProfileName(String name) async {
    try {
      final user = AuthService.to.currentUser;
      if (user == null) return false;

      await AuthService.to.updateDisplayName(name);
      await UserService.to.updateUserProfileName(user.uid, name);

      displayName.value = name;
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await AuthService.to.updatePassword(oldPassword, newPassword);
      Get.snackbar('Success', 'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password: $e',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
