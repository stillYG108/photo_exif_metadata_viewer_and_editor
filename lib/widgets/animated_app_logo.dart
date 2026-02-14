import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/forensic_theme.dart';

class AnimatedAppLogo extends StatefulWidget {
  final double size;
  const AnimatedAppLogo({super.key, this.size = 150});

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo> with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  // Glitch offsets
  double _offsetX = 0;
  double _offsetY = 0;
  double _opacity = 1.0;
  Color _glitchColor = ForensicColors.neonGreen;

  Timer? _glitchTimer;

  @override
  void initState() {
    super.initState();

    // Scanning line animation
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanAnimation = Tween<double>(begin: -0.2, end: 1.2).animate(CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    ));

    // Glitch effect timer
    _glitchTimer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      _triggerGlitch();
    });
  }

  void _triggerGlitch() {
    if (!mounted) return;

    // Random quick glitches
    int count = 0;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _offsetX = (DateTime.now().millisecond % 10 - 5).toDouble();
        _offsetY = (DateTime.now().millisecond % 10 - 5).toDouble();
        _opacity = 0.8 + (DateTime.now().millisecond % 20) / 100;
        _glitchColor = DateTime.now().millisecond % 2 == 0 
            ? ForensicColors.neonGreen 
            : ForensicColors.cyanAccent;
      });
      
      count++;
      if (count > 5) {
        timer.cancel();
        setState(() {
          _offsetX = 0;
          _offsetY = 0;
          _opacity = 1.0;
          _glitchColor = ForensicColors.neonGreen;
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _glitchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Logo
        _buildLogoImage(),
        
        // Glitch Layer 1 (Red/Cyan shift)
        if (_offsetX != 0)
          _buildGlitchLayer(Colors.red.withOpacity(0.6), _offsetX, 0),
          
        // Glitch Layer 2 (Green/Blue shift)
        if (_offsetY != 0)
          _buildGlitchLayer(Colors.blue.withOpacity(0.6), 0, _offsetY),

        // Scanning Line
        AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Positioned(
              top: widget.size * _scanAnimation.value,
              width: widget.size,
              height: 2,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: ForensicColors.neonGreen.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  color: ForensicColors.neonGreen,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoImage() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(
          color: ForensicColors.neonGreen.withOpacity(0.3),
          width: 1,
        ),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildGlitchLayer(Color color, double dx, double dy) {
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Opacity(
        opacity: 0.5,
        child: Container(
          width: widget.size,
          height: widget.size,
           child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            color: color,
            colorBlendMode: BlendMode.modulate,
          ),
        ),
      ),
    );
  }
}
