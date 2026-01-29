import 'package:flutter/material.dart';
import 'retro_button.dart';

/// 90s SYSTEM DIALOG
void showRetroDialog(
    BuildContext context, {
      required String title,
      required String message,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7CC),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ───── TITLE BAR ─────
            Container(
              height: 28,
              color: const Color(0xFF4A90E2),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

            // ───── MESSAGE ─────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message,
                style: const TextStyle(fontSize: 12),
              ),
            ),

            // ───── BUTTON ─────
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: 80,
                child: RetroButton(
                  text: "OK",
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
