import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/forensic_card.dart';
import '../../domain/entities/forensic_case.dart';
import 'case_status_badge.dart';
import 'case_priority_indicator.dart';

/// Case Card Widget
class CaseCard extends StatelessWidget {
  final ForensicCase forensicCase;
  final VoidCallback onTap;
  
  const CaseCard({
    Key? key,
    required this.forensicCase,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ForensicCard(
      elevated: true,
      borderColor: _getBorderColor(),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Case ID
              Expanded(
                child: Text(
                  forensicCase.caseId,
                  style: ForensicTypography.body(ColorConstants.textPrimary)
                      .copyWith(fontWeight: ForensicTypography.fontWeightBold),
                ),
              ),
              
              // Status badge
              CaseStatusBadge(status: forensicCase.status),
            ],
          ),
          
          SizedBox(height: ForensicSpacing.space8),
          
          // Title
          Text(
            forensicCase.title.toUpperCase(),
            style: ForensicTypography.body(ColorConstants.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          SizedBox(height: ForensicSpacing.space12),
          
          // Priority and evidence count
          Row(
            children: [
              CasePriorityIndicator(
                priority: forensicCase.priority,
                showLabel: true,
              ),
              
              const Spacer(),
              
              // Evidence count
              Icon(
                Icons.folder_outlined,
                color: ColorConstants.textSecondary,
                size: 16,
              ),
              SizedBox(width: ForensicSpacing.space4),
              Text(
                '${forensicCase.evidenceCount}',
                style: ForensicTypography.caption(ColorConstants.textSecondary),
              ),
            ],
          ),
          
          SizedBox(height: ForensicSpacing.space8),
          
          // Tags
          if (forensicCase.tags.isNotEmpty)
            Wrap(
              spacing: ForensicSpacing.space4,
              runSpacing: ForensicSpacing.space4,
              children: forensicCase.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ForensicSpacing.space8,
                    vertical: ForensicSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstants.borderInactive,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: ForensicTypography.caption(
                      ColorConstants.textTertiary,
                    ),
                  ),
                );
              }).toList(),
            ),
          
          SizedBox(height: ForensicSpacing.space8),
          
          // Timestamp
          Container(
            height: 1,
            color: ColorConstants.borderInactive,
          ),
          SizedBox(height: ForensicSpacing.space8),
          
          Text(
            '> CREATED: ${_formatDate(forensicCase.createdAt)}',
            style: ForensicTypography.caption(ColorConstants.textTertiary),
          ),
        ],
      ),
    );
  }
  
  Color _getBorderColor() {
    switch (forensicCase.priority) {
      case CasePriority.critical:
        return ColorConstants.forensicRed;
      case CasePriority.high:
        return ColorConstants.forensicAmber;
      case CasePriority.medium:
        return ColorConstants.forensicGreen;
      case CasePriority.low:
        return ColorConstants.forensicBlue;
    }
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
