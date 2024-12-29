import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/onboarding.dart';

Future<void> main() async {
  // Ensure Widgets are bound before asynchronous calls
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: "D:/SoftwareGradProject/SoftwareGProject/frontend/.env");

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Run the application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const OnboardingScreen(), // Set HomePage as the initial screen
    );
  }
}
