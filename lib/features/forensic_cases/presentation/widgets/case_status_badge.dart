import 'package:flutter/material.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../domain/entities/forensic_case.dart';

/// Case Status Badge
class CaseStatusBadge extends StatelessWidget {
  final CaseStatus status;
  
  const CaseStatusBadge({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ForensicSpacing.space8,
        vertical: ForensicSpacing.space4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: ForensicSpacing.borderMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        status.displayName,
        style: ForensicTypography.caption(_getTextColor()).copyWith(
          fontWeight: ForensicTypography.fontWeightBold,
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (status) {
      case CaseStatus.open:
        return ColorConstants.bgTertiary;
      case CaseStatus.investigating:
        return ColorConstants.bgTertiary;
      case CaseStatus.closed:
        return ColorConstants.bgSecondary;
      case CaseStatus.archived:
        return ColorConstants.bgSecondary;
    }
  }
  
  Color _getBorderColor() {
    switch (status) {
      case CaseStatus.open:
        return ColorConstants.forensicGreen;
      case CaseStatus.investigating:
        return ColorConstants.forensicAmber;
      case CaseStatus.closed:
        return ColorConstants.textSecondary;
      case CaseStatus.archived:
        return ColorConstants.textTertiary;
    }
  }
  
  Color _getTextColor() {
    switch (status) {
      case CaseStatus.open:
        return ColorConstants.forensicGreen;
      case CaseStatus.investigating:
        return ColorConstants.forensicAmber;
      case CaseStatus.closed:
        return ColorConstants.textSecondary;
      case CaseStatus.archived:
        return ColorConstants.textTertiary;
    }
  }
}
