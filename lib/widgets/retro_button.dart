import 'package:flutter/material.dart';

class RetroButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const RetroButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),

      child: Container(
        height: 36,
        padding: EdgeInsets.only(
          left: _pressed ? 10 : 12,
          right: _pressed ? 8 : 10,
          top: _pressed ? 8 : 6,
          bottom: _pressed ? 4 : 6,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFD0D0D0),
          border: Border(
            top: BorderSide(
              color: _pressed ? Colors.black54 : Colors.white,
              width: 2,
            ),
            left: BorderSide(
              color: _pressed ? Colors.black54 : Colors.white,
              width: 2,
            ),
            right: BorderSide(
              color: _pressed ? Colors.white : Colors.black54,
              width: 2,
            ),
            bottom: BorderSide(
              color: _pressed ? Colors.white : Colors.black54,
              width: 2,
            ),
          ),
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
