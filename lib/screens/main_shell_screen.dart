import 'package:flutter/material.dart';

import '../widgets/retro_window_chrome.dart';
import 'account_screen.dart';
import 'services_screen.dart';
import 'activity_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFBBD7EC),

        body: SafeArea(
          child: Column(
            children: [
              // ───────── HEADER ─────────
              _header(),

              // ───────── TOP NAV ─────────
              const TabBar(
                labelColor: Colors.black,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: "Services"),
                  Tab(text: "Activity"),
                  Tab(text: "Account"),
                ],
              ),

              // ───────── CONTENT ─────────
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7CC),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const TabBarView(
                    children: [
                      ServicesScreen(),
                      ActivityScreen(),
                      AccountScreen(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() => Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    color: const Color(0xFF4A90E2),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "EXIF FORENSICS WORKBENCH",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RetroWindowButtons(),
      ],
    ),
  );
}
