import 'package:flutter/material.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/forensic_case.dart';

/// Case Priority Indicator
class CasePriorityIndicator extends StatelessWidget {
  final CasePriority priority;
  final bool showLabel;
  
  const CasePriorityIndicator({
    Key? key,
    required this.priority,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Priority bars
        ...List.generate(4, (index) {
          final isActive = index < _getPriorityLevel();
          return Container(
            width: 4,
            height: 16,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: isActive ? _getPriorityColor() : ColorConstants.bgTertiary,
              border: Border.all(
                color: _getPriorityColor(),
                width: 1,
              ),
            ),
          );
        }),
        
        if (showLabel) ...[
          SizedBox(width: ForensicSpacing.space8),
          Text(
            priority.displayName,
            style: ForensicTypography.caption(_getPriorityColor()).copyWith(
              fontWeight: ForensicTypography.fontWeightBold,
            ),
          ),
        ],
      ],
    );
  }
  
  int _getPriorityLevel() {
    switch (priority) {
      case CasePriority.low:
        return 1;
      case CasePriority.medium:
        return 2;
      case CasePriority.high:
        return 3;
      case CasePriority.critical:
        return 4;
    }
  }
  
  Color _getPriorityColor() {
    switch (priority) {
      case CasePriority.low:
        return ColorConstants.forensicBlue;
      case CasePriority.medium:
        return ColorConstants.forensicGreen;
      case CasePriority.high:
        return ColorConstants.forensicAmber;
      case CasePriority.critical:
        return ColorConstants.forensicRed;
    }
  }
}
