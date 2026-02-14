import 'package:flutter/material.dart';

class SimpleTestScreen extends StatelessWidget {
  const SimpleTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "FORENSIC WORKSTATION",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00FF41), // Green
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "System Online",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFE0E0E0), // Off-white
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A0A0A),
                foregroundColor: const Color(0xFF00FF41),
                side: const BorderSide(color: Color(0xFF00FF41)),
              ),
              onPressed: () {},
              child: const Text("TEST BUTTON"),
            ),
          ],
        ),
      ),
    );
  }
}
