import 'package:flutter/material.dart';
import '../theme/color_constants.dart';
import '../theme/typography.dart';

class ForensicTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  
  const ForensicTextField({
    Key? key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  State<ForensicTextField> createState() => _ForensicTextFieldState();
}

class _ForensicTextFieldState extends State<ForensicTextField> {
  bool _isFocused = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          '> ${widget.label.toUpperCase()}',
          style: ForensicTypography.caption(
            _isFocused 
                ? ColorConstants.textPrimary 
                : ColorConstants.textSecondary,
          ),
        ),
        SizedBox(height: ForensicSpacing.space8),
        
        // Input field
        Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: Container(
            decoration: BoxDecoration(
              color: ColorConstants.bgSecondary,
              border: Border.all(
                color: _isFocused 
                    ? ColorConstants.borderPrimary 
                    : ColorConstants.borderSecondary,
                width: ForensicSpacing.borderMedium,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              style: ForensicTypography.body(ColorConstants.textPrimary),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: ForensicTypography.body(
                  ColorConstants.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(ForensicSpacing.space12),
                prefixText: '█ ',
                prefixStyle: ForensicTypography.body(
                  _isFocused 
                      ? ColorConstants.textPrimary 
                      : Colors.transparent,
                ),
              ),
              cursorColor: ColorConstants.textPrimary,
              cursorWidth: 8,
              cursorHeight: 16,
            ),
          ),
        ),
      ],
    );
  }
}
