import 'package:flutter/material.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

import 'package:Reflections/core/services/firebase_messaging_service.dart';

class SplashProvider extends ChangeNotifier {
  void initialize() {
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    if (AuthService.instance.currentUser != null) {
      // Bootstrap Firebase push messaging
      FirebaseMessagingService.instance.initialize();
      AppNavigator.goToHome();
    } else {
      AppNavigator.goToLogin();
    }
  }
}
