import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/app.dart';
import 'package:Reflections/core/localization/app_translations.dart';
import 'package:Reflections/core/providers/auth_provider.dart';
import 'package:Reflections/core/providers/note_provider.dart';
import 'package:Reflections/core/providers/login_provider.dart';
import 'package:Reflections/core/providers/register_provider.dart';
import 'package:Reflections/core/providers/search_provider.dart';
import 'package:Reflections/core/providers/settings_provider.dart';
import 'package:Reflections/core/providers/splash_provider.dart';
import 'package:Reflections/firebase_options.dart';
import 'package:Reflections/features/todo/state/todo_provider.dart';
import 'package:Reflections/features/habit/state/habit_provider.dart';
import 'package:Reflections/features/reminder/state/reminder_provider.dart';
import 'package:Reflections/features/reminder/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Local Notifications & Timed Alarms Init
  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: LanguageProvider.instance),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => RegisterProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
