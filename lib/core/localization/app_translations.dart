import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider instance = LanguageProvider._internal();
  LanguageProvider._internal();

  Locale _locale = const Locale('en', 'US');
  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }
}

extension TranslationExtension on String {
  String get tr {
    final lang = LanguageProvider.instance.locale.languageCode;
    final country = LanguageProvider.instance.locale.countryCode ?? 'US';
    final localeKey = '${lang}_$country';
    final translations = AppTranslations().keys[localeKey] ?? AppTranslations().keys['en_US']!;
    return translations[this] ?? this;
  }
}

class AppTranslations {
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'appName': 'Reflections',
          'appTagline': 'The quiet curator for your thoughts.',
          'loginTitle': 'Welcome Back',
          'loginSubtitle': 'Return to your reflections.',
          'loginButton': 'Login',
          'loginEmailHint': 'Enter your email',
          'loginPasswordHint': 'Enter your password',
          'loginForgotPassword': 'Forgot Password?',
          'loginNoAccount': 'New to Reflections? ',
          'loginCreateAccount': 'Create an account',
          'registerTitle': 'Begin.',
          'registerQuote': '"The quietest moments hold the loudest truths."',
          'registerNameHint': 'Full name',
          'registerEmailHint': 'Email address',
          'registerPasswordHint': 'Create a password',
          'registerButton': 'Create Account',
          'registerHaveAccount': 'Already have a space? ',
          'registerReturnLogin': 'Return to Login',
          'homeTitle': 'Thoughts',
          'homeSubtitle': 'A curated collection of your recent observations, ideas, and fleeting moments.',
          'homeEmpty': 'No notes yet.\nStart writing your first thought.',
          'homeEmptyAction': 'Write something',
          'addNoteTitle': 'New Note',
          'addNoteEdit': 'Edit Note',
          'addNoteSave': 'Save',
          'addNoteTitleHint': 'Give it a title...',
          'addNoteBodyHint': 'Start writing...',
          'settings': 'Settings',
          'settingsSubtitle': 'Manage your account and preferences.',
          'account': 'Account',
          'editProfile': 'Edit Profile',
          'changePassword': 'Change Password',
          'preferences': 'Preferences',
          'notifications': 'Notifications',
          'autoSaveDrafts': 'Auto-save drafts',
          'more': 'More',
          'totalNotes': 'Total Notes',
          'aboutReflections': 'About Reflections',
          'logOut': 'Log Out',
          'language': 'Language',
          'currentLanguage': 'English',
          'selectLanguage': 'Select Language',
          'pinned': 'Pinned',
          'unpinned': 'Unpinned',
          'noteColor': 'Note Color',
          'wordCount': 'words',
          'charCount': 'chars',
          'readTime': 'min read',
          'errorEmpty': 'This field cannot be empty',
          'errorEmail': 'Please enter a valid email address',
          'errorPassword': 'Password must be at least 6 characters',
        },
        'es_ES': {
          'appName': 'Reflections',
          'appTagline': 'El curador silencioso para tus pensamientos.',
          'loginTitle': 'Bienvenido de nuevo',
          'loginSubtitle': 'Regresa a tus reflexiones.',
          'loginButton': 'Iniciar Sesión',
          'loginEmailHint': 'Introduce tu correo',
          'loginPasswordHint': 'Introduce tu contraseña',
          'loginForgotPassword': '¿Olvidaste tu contraseña?',
          'loginNoAccount': '¿Nuevo en Reflections? ',
          'loginCreateAccount': 'Crea una cuenta',
          'registerTitle': 'Comienza.',
          'registerQuote': '"Los momentos más silenciosos albergan las verdades más ruidosas."',
          'registerNameHint': 'Nombre completo',
          'registerEmailHint': 'Correo electrónico',
          'registerPasswordHint': 'Crea una contraseña',
          'registerButton': 'Crear Cuenta',
          'registerHaveAccount': '¿Ya tienes un espacio? ',
          'registerReturnLogin': 'Volver al Inicio',
          'homeTitle': 'Pensamientos',
          'homeSubtitle': 'Una colección seleccionada de tus observaciones recientes, ideas y momentos fugaces.',
          'homeEmpty': 'Aún no hay notas.\nComienza a escribir tu primer pensamiento.',
          'homeEmptyAction': 'Escribir algo',
          'addNoteTitle': 'Nueva Nota',
          'addNoteEdit': 'Editar Nota',
          'addNoteSave': 'Guardar',
          'addNoteTitleHint': 'Dale un título...',
          'addNoteBodyHint': 'Comienza a escribir...',
          'settings': 'Ajustes',
          'settingsSubtitle': 'Gestiona tu cuenta y preferencias.',
          'account': 'Cuenta',
          'editProfile': 'Editar Perfil',
          'changePassword': 'Cambiar Contraseña',
          'preferences': 'Preferencias',
          'notifications': 'Notificaciones',
          'autoSaveDrafts': 'Autoguardar borradores',
          'more': 'Más',
          'totalNotes': 'Notas Totales',
          'aboutReflections': 'Acerca de Reflections',
          'logOut': 'Cerrar Sesión',
          'language': 'Idioma',
          'currentLanguage': 'Español',
          'selectLanguage': 'Seleccionar Idioma',
          'pinned': 'Fijado',
          'unpinned': 'Desfijado',
          'noteColor': 'Color de Nota',
          'wordCount': 'palabras',
          'charCount': 'caracteres',
          'readTime': 'min de lectura',
          'errorEmpty': 'Este campo no puede estar vacío',
          'errorEmail': 'Por favor introduce un correo válido',
          'errorPassword': 'La contraseña debe tener al menos 6 caracteres',
        }
      };
}
