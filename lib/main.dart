import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:Reflections/app.dart';
import 'package:Reflections/core/services/auth_service.dart';
import 'package:Reflections/core/services/note_service.dart';
import 'package:Reflections/core/services/user_service.dart';
import 'package:Reflections/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Firebase Services
  Get.put(AuthService());
  Get.put(UserService());
  Get.put(NoteService());

  runApp(const MyApp());
}
