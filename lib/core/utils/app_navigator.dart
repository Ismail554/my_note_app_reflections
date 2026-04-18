import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Reflections/routes/app_routes.dart';
import 'package:Reflections/shared/models/note_model.dart';

/// Helper to navigate via GoRouter from outside widget context (controllers)
class AppNavigator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get _context => navigatorKey.currentContext;

  static void goToLogin() {
    _context?.go(AppRoutes.login);
  }

  static void goToRegister() {
    _context?.push(AppRoutes.register);
  }

  static void goToHome() {
    _context?.go(AppRoutes.home);
  }

  static void goToAddNote({NoteModel? note}) {
    _context?.push(AppRoutes.addNote, extra: note);
  }

  static void goBack() {
    if (_context?.canPop() ?? false) {
      _context?.pop();
    }
  }
}
