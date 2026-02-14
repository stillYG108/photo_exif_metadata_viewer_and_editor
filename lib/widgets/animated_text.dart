import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/forensic_theme.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final bool loop;

  const AnimatedText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 50),
    this.loop = false,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  String _displayedText = "";
  int _currentIndex = 0;
  Timer? _timer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        if (widget.loop) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _displayedText = "";
                _currentIndex = 0;
                _startTyping();
              });
            }
          });
        }
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _showCursor = !_showCursor;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? Theme.of(context).textTheme.bodyLarge;
    
    return RichText(
      softWrap: true,
      overflow: TextOverflow.visible,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: _displayedText),
          if (_currentIndex < widget.text.length || _showCursor)
            TextSpan(
              text: "█",
              style: style?.copyWith(
                color: (style.color ?? ForensicColors.greenPrimary).withOpacity(_showCursor ? 1.0 : 0.0),
              ),
            ),
        ],
      ),
    );
  }
}
