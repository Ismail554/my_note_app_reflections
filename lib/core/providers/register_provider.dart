import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/services/user_service.dart';
import 'package:Reflections/core/utils/app_navigator.dart';

class RegisterProvider extends ChangeNotifier {
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

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final userCredential = await AuthService.instance.registerWithEmailAndPassword(
        email,
        password,
      );

      final user = userCredential.user;
      if (user != null) {
        await AuthService.instance.updateDisplayName(name);
        await UserService.instance.createUserProfile(
          uid: user.uid,
          name: name,
          email: email,
        );
        AppNavigator.goToHome();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        _errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        _errorMessage = 'The email address is not valid.';
      } else {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void navigateToLogin() {
    AppNavigator.goBack();
  }
}
