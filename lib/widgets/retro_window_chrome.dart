import 'package:flutter/material.dart';

class RetroWindowButtons extends StatelessWidget {
  const RetroWindowButtons({super.key});

  Widget _windowButton({
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16,
        height: 16,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: color,
          border: const Border(
            top: BorderSide(color: Colors.white, width: 2),
            left: BorderSide(color: Colors.white, width: 2),
            right: BorderSide(color: Colors.black54, width: 2),
            bottom: BorderSide(color: Colors.black54, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // MINIMIZE (green-ish)
        _windowButton(
          color: const Color(0xFF6BCF63),
          onTap: () {
            // intentionally empty (visual only)
          },
        ),

        // MAXIMIZE (yellow-ish)
        _windowButton(
          color: const Color(0xFFFFC857),
          onTap: () {
            // intentionally empty (visual only)
          },
        ),

        // CLOSE (red)
        _windowButton(
          color: const Color(0xFFEF6F6C),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
