import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool active;

  const GlitchText(
    this.text, {
    super.key,
    this.style,
    this.active = true,
  });

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _glitchTimer;
  final Random _random = Random();
  
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  Color? _colorOverride;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    
    if (widget.active) {
      _startGlitchLoop();
    }
  }

  void _startGlitchLoop() {
    // Random glitch intervals between 2s and 5s
    _glitchTimer = Timer.periodic(
      Duration(milliseconds: 2000 + _random.nextInt(3000)), 
      (timer) {
        if (!mounted) return;
        _triggerGlitch();
      }
    );
  }

  void _triggerGlitch() async {
    // Perform rapid shifts for a short duration
    for (int i = 0; i < 5; i++) {
        if (!mounted) break;
        setState(() {
          _offsetX = (_random.nextDouble() - 0.5) * 4.0;
          _offsetY = (_random.nextDouble() - 0.5) * 2.0;
          _colorOverride = _random.nextBool() ? Colors.red : Colors.cyan;
        });
        await Future.delayed(const Duration(milliseconds: 50));
    }
    
    if (mounted) {
      setState(() {
        _offsetX = 0;
        _offsetY = 0;
        _colorOverride = null;
      });
    }
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Text(widget.text, style: widget.style);
    }
    
    // Create RGB Split effect
    return Stack(
      children: [
        // Cyan Channel
        Transform.translate(
          offset: Offset(_offsetX * 1.5, _offsetY),
          child: Text(
            widget.text,
            style: widget.style?.copyWith(color: Colors.cyan.withOpacity(0.7)),
          ),
        ),
        // Red Channel
        Transform.translate(
          offset: Offset(-_offsetX, -_offsetY),
          child: Text(
            widget.text,
            style: widget.style?.copyWith(color: Colors.red.withOpacity(0.7)),
          ),
        ),
        // Main Text
        Transform.translate(
          offset: Offset(_offsetX / 2, 0),
          child: Text(
            widget.text,
            style: widget.style,
          ),
        ),
      ],
    );
  }
}
