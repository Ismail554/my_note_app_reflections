import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:Reflections/app.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/services/note_service.dart';
import 'package:Reflections/core/services/user_service.dart';
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

  // Firebase Services
  Get.put(AuthService());
  Get.put(UserService());
  Get.put(NoteService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
