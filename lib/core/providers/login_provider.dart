import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

import 'package:Reflections/core/services/firebase_messaging_service.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _obscurePassword = true;
    _errorMessage = '';
  }

  Future<void> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      await AuthService.instance.signInWithEmailAndPassword(email, password);
      // Initialize Firebase messaging notifications
      FirebaseMessagingService.instance.initialize();
      AppNavigator.goToHome();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _errorMessage = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'The email address is not valid.';
      } else {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please check your credentials.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToRegister() {
    AppNavigator.goToRegister();
  }
}
