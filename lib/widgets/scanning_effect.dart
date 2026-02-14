import 'package:flutter/material.dart';
import '../../core/theme/forensic_theme.dart';

class ScanningEffect extends StatefulWidget {
  final Widget child;
  final bool isScanning;
  final Color? scanColor;

  const ScanningEffect({
    super.key,
    required this.child,
    this.isScanning = true,
    this.scanColor,
  });

  @override
  State<ScanningEffect> createState() => _ScanningEffectState();
}

class _ScanningEffectState extends State<ScanningEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isScanning) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScanningEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isScanning)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanLayerPainter(
                    progress: _controller.value,
                    color: widget.scanColor ?? ForensicColors.neonGreen,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ScanLayerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanLayerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;
      
    final yPos = size.height * progress;
    
    // Draw the main scan line
    canvas.drawRect(
      Rect.fromLTWH(0, yPos, size.width, 2), 
      Paint()..color = color..shader = LinearGradient(
        colors: [
          color.withOpacity(0), 
          color, 
          color.withOpacity(0)
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, yPos, size.width, 2))
    );

    // Draw a trailing gradient "light"
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.2),
      ],
      stops: const [0.0, 1.0],
    );

    // trailing rectangle behind the line (if moving down)
    // or ahead (if moving up) - simplistic implementation assumes straight down for visual effect
    // To make it look like a scanner beam
    
    final beamHeight = 40.0;
    // We only draw the beam trail "above" the line effectively
    final beamRect = Rect.fromLTWH(0, yPos - beamHeight, size.width, beamHeight);
    
    canvas.drawRect(
      beamRect,
      Paint()..shader = gradient.createShader(beamRect),
    );
  }

  @override
  bool shouldRepaint(_ScanLayerPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
