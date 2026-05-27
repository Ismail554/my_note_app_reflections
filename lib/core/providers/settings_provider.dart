import 'package:flutter/material.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/services/user_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

import 'package:Reflections/core/services/firebase_messaging_service.dart';

class SettingsProvider extends ChangeNotifier {
  String _displayName = '';
  String _email = '';
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  String _currentLanguage = 'English';

  String get displayName => _displayName;
  String get email => _email;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  String get currentLanguage => _currentLanguage;

  SettingsProvider() {
    loadUserData();
    _initLanguage();
  }

  void _initLanguage() {
    final locale = LanguageProvider.instance.locale;
    if (locale.languageCode == 'es') {
      _currentLanguage = 'Español';
    } else {
      _currentLanguage = 'English';
    }
  }

  void changeLanguage(String langCode) {
    if (langCode == 'es') {
      LanguageProvider.instance.changeLocale(const Locale('es', 'ES'));
      _currentLanguage = 'Español';
    } else {
      LanguageProvider.instance.changeLocale(const Locale('en', 'US'));
      _currentLanguage = 'English';
    }
    notifyListeners();
  }

  void loadUserData() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _displayName = user.displayName ?? 'User';
      _email = user.email ?? '';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.instance.signOut();
    AppNavigator.goToLogin();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    FirebaseMessagingService.instance.enableNotifications(value);
    notifyListeners();
  }

  void toggleAutoSave(bool value) {
    _autoSaveEnabled = value;
    notifyListeners();
  }

  Future<bool> updateProfileName(String name) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return false;

      await AuthService.instance.updateDisplayName(name);
      await UserService.instance.updateUserProfileName(user.uid, name);

      _displayName = name;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await AuthService.instance.updatePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }
}
