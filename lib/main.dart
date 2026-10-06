import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_practice/firebase_options.dart';
import 'package:flutter_practice/my_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration must be available before any widget is built.
  // `isOptional: true` keeps a fresh checkout running even without a .env file
  // - every AppConfig key then falls back to its built-in dev default.
  await dotenv.load(isOptional: true);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
