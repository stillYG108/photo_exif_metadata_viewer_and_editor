import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF7CC), // classic beige workspace
      padding: const EdgeInsets.all(12),

      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _DesktopToolTile(
            "EXIF Metadata\nAnalyzer",
            Icons.image,
          ),
          _DesktopToolTile(
            "Metadata\nEditor",
            Icons.edit,
          ),
          _DesktopToolTile(
            "Forensic PDF\nReport",
            Icons.picture_as_pdf,
          ),
          _DesktopToolTile(
            "Evidence\nExport Tool",
            Icons.folder_zip,
          ),
        ],
      ),
    );
  }
}

/// ───────── DESKTOP ICON TILE (TRUE 90s STYLE) ─────────
class _DesktopToolTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DesktopToolTile(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: const BoxDecoration(
        color: Color(0xFFD6D6D6), // classic desktop gray
        border: Border(
          top: BorderSide(color: Colors.white, width: 3),
          left: BorderSide(color: Colors.white, width: 3),
          right: BorderSide(color: Colors.black54, width: 3),
          bottom: BorderSide(color: Colors.black54, width: 3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ───────── ICON BOX ─────────
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
              border: Border(
                top: BorderSide(color: Colors.white, width: 2),
                left: BorderSide(color: Colors.white, width: 2),
                right: BorderSide(color: Colors.black54, width: 2),
                bottom: BorderSide(color: Colors.black54, width: 2),
              ),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 8),

          // ───────── LABEL (LIKE FILE NAME) ─────────
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
