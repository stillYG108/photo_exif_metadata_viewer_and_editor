import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../widgets/retro_window_chrome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestore() async {
  await FirebaseFirestore.instance
      .collection('system')
      .doc('health')
      .set({'status': 'ok'});
}


class PublicDashboardScreen extends StatelessWidget {
  const PublicDashboardScreen({super.key});

  // ───────── LOGIN REQUIRED POPUP ─────────
  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFF7CC),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text(
          "LOGIN REQUIRED",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Please login to access forensic services.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text("LOGIN"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBBD7EC),

      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 420,
            height: MediaQuery.of(context).size.height * 0.95,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7CC),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              children: [
                // ───────── HEADER ─────────
                _retroHeader(),

                // ───────── BODY ─────────
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _toolTile("EXIF Analyzer", context),
                      _toolTile("Metadata Editor", context),
                      _toolTile("Forensic PDF Report", context),
                      _toolTile("Evidence Export Tool", context),
                    ],
                  ),
                ),

                // ───────── FOOTER ─────────
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Login required to access services",
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ───────── TOOL TILE ─────────
  Widget _toolTile(String title, BuildContext context) {
    return GestureDetector(
      onTap: () => _showLoginPrompt(context),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFC857),
          border: Border(
            top: BorderSide(color: Colors.white, width: 4),
            left: BorderSide(color: Colors.white, width: 4),
            right: BorderSide(color: Colors.black54, width: 4),
            bottom: BorderSide(color: Colors.black54, width: 4),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  // ───────── RETRO HEADER ─────────
  Widget _retroHeader() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF6AC36A),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "EXIF FORENSICS TOOLKIT",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RetroWindowButtons(),
        ],
      ),
    );
  }
}
