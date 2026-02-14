import 'package:flutter/material.dart';

/// Scanline Overlay Effect
/// Creates authentic CRT monitor scanline effect
class ScanlineOverlay extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double lineHeight;
  
  const ScanlineOverlay({
    Key? key,
    required this.child,
    this.opacity = 0.1,
    this.lineHeight = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinePainter(
                opacity: opacity,
                lineHeight: lineHeight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final double opacity;
  final double lineHeight;
  
  _ScanlinePainter({
    required this.opacity,
    required this.lineHeight,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..strokeWidth = lineHeight;
    
    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += lineHeight * 2) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
           oldDelegate.lineHeight != lineHeight;
  }
}
