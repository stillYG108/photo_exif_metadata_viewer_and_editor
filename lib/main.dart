import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/main_shell_screen.dart';
import 'screens/public_dashboard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestore() async {
  await FirebaseFirestore.instance
      .collection('system')
      .doc('ping')
      .set({
    'ok': true,
    'time': FieldValue.serverTimestamp(),
  });
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RetroForensicsApp());
}


class RetroForensicsApp extends StatelessWidget {
  const RetroForensicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EXIF Forensics Workbench',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFBBD7EC),
        fontFamily: 'monospace',

        // 🪟 90s Dialog Theme
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFFFFF7CC),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 2),
          ),
          titleTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          contentTextStyle: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: const Color(0xFFEFEFEF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            side: const BorderSide(color: Colors.black, width: 2),
            shape: const BeveledRectangleBorder(),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),

      home: const AuthGate(),
    );
  }
}

/// 🔐 AUTH GATE — SINGLE SOURCE OF TRUTH
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainShellScreen();
        }

        return const PublicDashboardScreen();
      },
    );
  }
}
