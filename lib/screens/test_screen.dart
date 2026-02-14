import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/forensic_theme.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForensicColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "FORENSIC WORKSTATION",
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ForensicColors.greenPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "System Online",
              style: GoogleFonts.shareTechMono(
                fontSize: 16,
                color: ForensicColors.textPrimary,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {},
              child: const Text("TEST BUTTON"),
            ),
          ],
        ),
      ),
    );
  }
}
