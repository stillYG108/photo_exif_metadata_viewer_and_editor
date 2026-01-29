import 'package:flutter/material.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF7CC), // retro beige
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionTitle("Recent Activity"),

          SizedBox(height: 8),

          _LogItem("✔ Login successful"),
          _LogItem("🖼 EXIF metadata viewed"),
          _LogItem("✏ Metadata edited"),
          _LogItem("📄 PDF forensic report generated"),
          _LogItem("📦 Evidence exported"),
          _LogItem("⏻ User logged out"),
        ],
      ),
    );
  }
}

/// ───────── SECTION TITLE (90s style) ─────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// ───────── ACTIVITY LOG ITEM ─────────
class _LogItem extends StatelessWidget {
  final String text;
  const _LogItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        border: Border(
          top: const BorderSide(color: Colors.white, width: 3),
          left: const BorderSide(color: Colors.white, width: 3),
          right: const BorderSide(color: Colors.black54, width: 3),
          bottom: const BorderSide(color: Colors.black54, width: 3),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
