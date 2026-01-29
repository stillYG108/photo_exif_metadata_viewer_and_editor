import 'package:flutter/material.dart';

class RetroCheckbox extends StatefulWidget {
  final String label;

  const RetroCheckbox({super.key, required this.label});

  @override
  State<RetroCheckbox> createState() => _RetroCheckboxState();
}

class _RetroCheckboxState extends State<RetroCheckbox> {
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => checked = !checked),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: checked ? Colors.black54 : Colors.white,
                  width: 2,
                ),
                left: BorderSide(
                  color: checked ? Colors.black54 : Colors.white,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: checked ? Colors.white : Colors.black54,
                  width: 2,
                ),
                right: BorderSide(
                  color: checked ? Colors.white : Colors.black54,
                  width: 2,
                ),
              ),
            ),
            child: checked
                ? const Center(
              child: Icon(Icons.check, size: 14),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(widget.label),
        ],
      ),
    );
  }
}
