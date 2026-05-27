import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Reflections/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  StreamSubscription<User?>? _authSubscription;

  AuthProvider() {
    _currentUser = AuthService.instance.currentUser;
    _authSubscription = AuthService.instance.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> updateDisplayName(String name) async {
    await AuthService.instance.updateDisplayName(name);
    _currentUser = AuthService.instance.currentUser;
    notifyListeners();
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    await AuthService.instance.updatePassword(oldPassword, newPassword);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
