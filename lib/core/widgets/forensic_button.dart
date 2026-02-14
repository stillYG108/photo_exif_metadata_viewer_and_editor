import 'package:flutter/material.dart';
import '../theme/color_constants.dart';
import '../theme/typography.dart';

enum ButtonSize { small, medium, large }

class ForensicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;
  final IconData? icon;
  final ButtonSize size;
  
  const ForensicButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.color,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
  }) : super(key: key);

  @override
  State<ForensicButton> createState() => _ForensicButtonState();
}

class _ForensicButtonState extends State<ForensicButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final borderColor = widget.color ?? ColorConstants.borderPrimary;
    
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        padding: _getPadding(),
        decoration: BoxDecoration(
          color: _isPressed 
              ? ColorConstants.bgTertiary 
              : ColorConstants.bgSecondary,
          border: Border.all(
            color: isEnabled ? borderColor : ColorConstants.borderInactive,
            width: ForensicSpacing.borderMedium,
          ),
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: borderColor,
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null && !widget.isLoading) ...[
              Icon(
                widget.icon,
                color: isEnabled 
                    ? ColorConstants.textPrimary 
                    : ColorConstants.textDisabled,
                size: _getIconSize(),
              ),
              SizedBox(width: ForensicSpacing.space8),
            ],
            if (widget.isLoading)
              SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(ColorConstants.textPrimary),
                ),
              )
            else
              Text(
                widget.label.toUpperCase(),
                style: ForensicTypography.body(
                  isEnabled 
                      ? ColorConstants.textPrimary 
                      : ColorConstants.textDisabled,
                ).copyWith(
                  fontSize: _getFontSize(),
                  fontWeight: ForensicTypography.fontWeightBold,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: ForensicSpacing.space12,
          vertical: ForensicSpacing.space8,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: ForensicSpacing.space16,
          vertical: ForensicSpacing.space12,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: ForensicSpacing.space24,
          vertical: ForensicSpacing.space16,
        );
    }
  }
  
  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }
  
  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return ForensicTypography.fontSizeSM;
      case ButtonSize.medium:
        return ForensicTypography.fontSizeMD;
      case ButtonSize.large:
        return ForensicTypography.fontSizeLG;
    }
  }
}
