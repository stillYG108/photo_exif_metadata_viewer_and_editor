import 'package:flutter/material.dart';
import '../theme/color_constants.dart';
import '../theme/typography.dart';

class ForensicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool elevated;
  
  const ForensicCard({
    Key? key,
    required this.child,
    this.title,
    this.borderColor,
    this.onTap,
    this.elevated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? ColorConstants.borderPrimary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.bgSecondary,
          border: Border.all(
            color: effectiveBorderColor,
            width: ForensicSpacing.borderMedium,
          ),
          boxShadow: elevated ? [
            BoxShadow(
              color: effectiveBorderColor,
              blurRadius: 0,
              offset: const Offset(4, 4),
            ),
          ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(ForensicSpacing.space12),
                decoration: BoxDecoration(
                  color: ColorConstants.bgTertiary,
                  border: Border(
                    bottom: BorderSide(
                      color: effectiveBorderColor,
                      width: ForensicSpacing.borderMedium,
                    ),
                  ),
                ),
                child: Text(
                  title!.toUpperCase(),
                  style: ForensicTypography.body(ColorConstants.textPrimary)
                      .copyWith(fontWeight: ForensicTypography.fontWeightBold),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(ForensicSpacing.space16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
