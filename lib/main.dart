import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/forensic_theme.dart';
import 'screens/main_shell_screen.dart';
import 'screens/public_dashboard_screen.dart';
import 'widgets/glitch_text.dart';
import 'widgets/scanning_effect.dart';
import 'services/notification_service.dart';

/// Test Firestore connection
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
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Notification Service (local + FCM)
  await NotificationService().initialize();
  
  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Wrap app with ProviderScope for Riverpod
  runApp(const ProviderScope(child: ExifForensicsApp()));
}

/// Main Application Widget
class ExifForensicsApp extends StatelessWidget {
  const ExifForensicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EXIF Forensics Workbench',
      
      // Use Forensic Theme (Green Terminal)
      theme: ForensicTheme.getTheme(),
      
      home: const AuthGate(),
    );
  }
}

/// Authentication Gate - Routes to appropriate screen based on auth state
/// Includes "Biometric Scan" loading effect.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _BiometricLoadingScreen();
        }

        // Authenticated - go to main shell
        if (snapshot.hasData) {
          return const MainShellScreen();
        }

        // Not authenticated - go to public dashboard
        return const PublicDashboardScreen();
      },
    );
  }
}

class _BiometricLoadingScreen extends StatelessWidget {
  const _BiometricLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForensicColors.background,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fingerprint, 
                  size: 80, 
                  color: ForensicColors.neonGreen
                ),
                const SizedBox(height: 20),
                GlitchText(
                  "IDENTITY VERIFICATION IN PROGRESS...",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.neonGreen,
                    fontSize: 16,
                    letterSpacing: 2.0
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "ACCESSING SECURE DATA ENCLAVE",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Scan effect over the whole screen
          const Positioned.fill(
             child: ScanningEffect(
               isScanning: true,
               child: SizedBox.expand(),
             ),
          ),
        ],
      ),
    );
  }
}
