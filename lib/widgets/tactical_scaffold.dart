import 'package:flutter/material.dart';
import '../../core/theme/forensic_theme.dart';
import 'crt_effect_container.dart';

class TacticalScaffold extends StatelessWidget {
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar;
  final bool enableScanlines;

  const TacticalScaffold({
    super.key,
    this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.enableScanlines = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForensicColors.background,
      appBar: appBar,
      body: Stack(
        children: [
          // 1. Grid Background Layer
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: ForensicColors.gridLine,
                spacing: 30.0,
              ),
            ),
          ),
          
          // 2. Main Content
          if (body != null)
            SafeArea(
              child: Column(
                children: [
                  // Tactical Status Bar
                  _buildStatusBar(context),
                  Expanded(child: body!),
                ],
              ),
            ),

          // 3. Scanline / Vignette Overlay (CRT Effect)
          if (enableScanlines)
             const Positioned.fill(
               child: IgnorePointer(
                 child: CrtEffectContainer(
                   child: SizedBox.expand(), 
                   enableCurve: false, 
                   enableScanlines: true, 
                   enableVignette: true
                 ),
               ),
             ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      height: 24,
      width: double.infinity,
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              "SYS.SECURE // ENCRYPTION: AES-256",
              style: TextStyle(
                color: ForensicColors.textSecondary,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "SESSION_ID: 0X99-ALPHA",
              style: TextStyle(
                color: ForensicColors.neonGreen.withOpacity(0.7),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _GridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    // Vertical Lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal Lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
