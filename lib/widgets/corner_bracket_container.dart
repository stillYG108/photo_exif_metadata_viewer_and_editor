import 'package:flutter/material.dart';
import '../../core/theme/forensic_theme.dart';

class CornerBracketContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double strokeWidth;
  final double bracketLength;
  final EdgeInsets padding;

  const CornerBracketContainer({
    super.key,
    required this.child,
    this.color,
    this.strokeWidth = 2.0,
    this.bracketLength = 15.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final bracketColor = color ?? Theme.of(context).primaryColor;

    return CustomPaint(
      painter: _CornerBracketPainter(
        color: bracketColor,
        strokeWidth: strokeWidth,
        bracketLength: bracketLength,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double bracketLength;

  _CornerBracketPainter({
    required this.color,
    required this.strokeWidth,
    required this.bracketLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final double w = size.width;
    final double h = size.height;
    final double l = bracketLength;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, l)
        ..lineTo(0, 0)
        ..lineTo(l, 0),
      paint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(w - l, 0)
        ..lineTo(w, 0)
        ..lineTo(w, l),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(w, h - l)
        ..lineTo(w, h)
        ..lineTo(w - l, h),
      paint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(l, h)
        ..lineTo(0, h)
        ..lineTo(0, h - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.bracketLength != bracketLength;
}
