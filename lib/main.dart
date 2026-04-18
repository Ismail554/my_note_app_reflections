import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_notes/app.dart';
import 'package:my_notes/core/services/auth_service.dart';
import 'package:my_notes/core/services/note_service.dart';
import 'package:my_notes/core/services/user_service.dart';
import 'package:my_notes/firebase_options.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase Services
  Get.put(AuthService());
  Get.put(UserService());
  Get.put(NoteService());

  runApp(const MyApp());
}
