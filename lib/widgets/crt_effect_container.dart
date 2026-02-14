import 'dart:math';
import 'package:flutter/material.dart';

class CrtEffectContainer extends StatelessWidget {
  final Widget child;
  final bool enableCurve;
  final bool enableScanlines;
  final bool enableVignette;

  const CrtEffectContainer({
    super.key,
    required this.child,
    this.enableCurve = true,
    this.enableScanlines = true,
    this.enableVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (enableScanlines) {
      content = Stack(
        children: [
          content,
          const Positioned.fill(
            child: IgnorePointer(
              child: _ScanlineOverlay(),
            ),
          ),
        ],
      );
    }

    if (enableVignette) {
      content = Stack(
        children: [
          content,
          const Positioned.fill(
            child: IgnorePointer(
              child: _VignetteOverlay(),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanlinePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15) // Dark lines
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VignetteOverlay extends StatelessWidget {
  const _VignetteOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.6, 0.8, 0.9, 1.0],
        ),
      ),
    );
  }
}
