import 'package:flutter/material.dart';
import '../theme/color_constants.dart';
import '../theme/typography.dart';

class ForensicLoadingIndicator extends StatelessWidget {
  final String message;
  final bool showProgress;
  final double? progress;
  
  const ForensicLoadingIndicator({
    Key? key,
    this.message = 'PROCESSING...',
    this.showProgress = false,
    this.progress,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space24),
      decoration: BoxDecoration(
        color: ColorConstants.bgPrimary,
        border: Border.all(
          color: ColorConstants.borderPrimary,
          width: ForensicSpacing.borderMedium,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Blinking cursor animation
          const _BlinkingCursor(),
          SizedBox(height: ForensicSpacing.space16),
          Text(
            message.toUpperCase(),
            style: ForensicTypography.body(ColorConstants.textPrimary),
            textAlign: TextAlign.center,
          ),
          if (showProgress) ...[
            SizedBox(height: ForensicSpacing.space16),
            _RetroProgressBar(progress: progress),
          ],
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        '█',
        style: ForensicTypography.header2(ColorConstants.textPrimary),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _RetroProgressBar extends StatelessWidget {
  final double? progress;
  
  const _RetroProgressBar({this.progress});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.borderPrimary,
          width: ForensicSpacing.borderMedium,
        ),
      ),
      child: progress != null
          ? _DeterminateProgress(progress: progress!)
          : const _IndeterminateProgress(),
    );
  }
}

class _DeterminateProgress extends StatelessWidget {
  final double progress;
  
  const _DeterminateProgress({required this.progress});
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth * progress;
        
        return Stack(
          children: [
            Container(color: ColorConstants.bgSecondary),
            Container(
              width: width,
              color: ColorConstants.borderPrimary,
            ),
            Center(
              child: Text(
                '${(progress * 100).toInt()}%',
                style: ForensicTypography.body(ColorConstants.textPrimary)
                    .copyWith(fontWeight: ForensicTypography.fontWeightBold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IndeterminateProgress extends StatefulWidget {
  const _IndeterminateProgress();

  @override
  State<_IndeterminateProgress> createState() => _IndeterminateProgressState();
}

class _IndeterminateProgressState extends State<_IndeterminateProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: _controller.value,
          backgroundColor: ColorConstants.bgSecondary,
          valueColor: const AlwaysStoppedAnimation(ColorConstants.borderPrimary),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
