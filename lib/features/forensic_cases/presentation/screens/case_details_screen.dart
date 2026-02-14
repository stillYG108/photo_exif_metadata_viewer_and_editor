import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/forensic_button.dart';
import '../../../../core/widgets/forensic_card.dart';
import '../controllers/forensic_case_controller.dart';
import '../widgets/scanline_overlay.dart';
import '../widgets/case_status_badge.dart';
import '../widgets/case_priority_indicator.dart';
import '../../domain/entities/forensic_case.dart';
import 'edit_case_screen.dart';

/// Case Details Screen
class CaseDetailsScreen extends ConsumerWidget {
  final ForensicCase forensicCase;
  
  const CaseDetailsScreen({
    Key? key,
    required this.forensicCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ScanlineOverlay(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ForensicSpacing.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCaseInfo(),
                    SizedBox(height: ForensicSpacing.space16),
                    _buildDescription(),
                    SizedBox(height: ForensicSpacing.space16),
                    _buildMetadata(),
                    SizedBox(height: ForensicSpacing.space16),
                    _buildTimeline(),
                    SizedBox(height: ForensicSpacing.space16),
                    _buildActions(context, ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space16),
      decoration: BoxDecoration(
        color: ColorConstants.bgTertiary,
        border: Border(
          top: BorderSide(
            color: _getBorderColor(),
            width: 3,
          ),
          bottom: BorderSide(
            color: ColorConstants.borderPrimary,
            width: ForensicSpacing.borderMedium,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: ColorConstants.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: ForensicSpacing.space8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    forensicCase.caseId,
                    style: ForensicTypography.header2(ColorConstants.textPrimary),
                  ),
                  Text(
                    '> CASE DETAILS',
                    style: ForensicTypography.caption(ColorConstants.textSecondary),
                  ),
                ],
              ),
            ),
            CaseStatusBadge(status: forensicCase.status),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCaseInfo() {
    return ForensicCard(
      title: 'CASE INFORMATION',
      borderColor: _getBorderColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            forensicCase.title.toUpperCase(),
            style: ForensicTypography.body(ColorConstants.textPrimary)
                .copyWith(fontWeight: ForensicTypography.fontWeightBold),
          ),
          
          SizedBox(height: ForensicSpacing.space16),
          
          // Priority
          Row(
            children: [
              Text(
                '> PRIORITY:',
                style: ForensicTypography.caption(ColorConstants.textSecondary),
              ),
              SizedBox(width: ForensicSpacing.space8),
              CasePriorityIndicator(priority: forensicCase.priority),
            ],
          ),
          
          SizedBox(height: ForensicSpacing.space12),
          
          // Evidence count
          Row(
            children: [
              Text(
                '> EVIDENCE FILES:',
                style: ForensicTypography.caption(ColorConstants.textSecondary),
              ),
              SizedBox(width: ForensicSpacing.space8),
              Text(
                '${forensicCase.evidenceCount}',
                style: ForensicTypography.body(ColorConstants.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDescription() {
    return ForensicCard(
      title: 'DESCRIPTION',
      child: Text(
        forensicCase.description,
        style: ForensicTypography.body(ColorConstants.textSecondary),
      ),
    );
  }
  
  Widget _buildMetadata() {
    return ForensicCard(
      title: 'METADATA',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetadataRow('CREATED BY', forensicCase.createdByEmail),
          SizedBox(height: ForensicSpacing.space8),
          _buildMetadataRow('CREATED AT', _formatDate(forensicCase.createdAt)),
          SizedBox(height: ForensicSpacing.space8),
          _buildMetadataRow('LAST UPDATED', _formatDate(forensicCase.updatedAt)),
          
          if (forensicCase.assignedToEmail != null) ...[
            SizedBox(height: ForensicSpacing.space8),
            _buildMetadataRow('ASSIGNED TO', forensicCase.assignedToEmail!),
          ],
          
          if (forensicCase.closedAt != null) ...[
            SizedBox(height: ForensicSpacing.space8),
            _buildMetadataRow('CLOSED AT', _formatDate(forensicCase.closedAt!)),
          ],
          
          if (forensicCase.tags.isNotEmpty) ...[
            SizedBox(height: ForensicSpacing.space12),
            Text(
              '> TAGS:',
              style: ForensicTypography.caption(ColorConstants.textSecondary),
            ),
            SizedBox(height: ForensicSpacing.space8),
            Wrap(
              spacing: ForensicSpacing.space4,
              runSpacing: ForensicSpacing.space4,
              children: forensicCase.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ForensicSpacing.space8,
                    vertical: ForensicSpacing.space4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstants.borderSecondary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: ForensicTypography.caption(ColorConstants.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildMetadataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '> $label:',
            style: ForensicTypography.caption(ColorConstants.textTertiary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: ForensicTypography.caption(ColorConstants.textSecondary),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTimeline() {
    if (forensicCase.timeline.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ForensicCard(
      title: 'ACTIVITY TIMELINE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: forensicCase.timeline.map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: ForensicSpacing.space8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '█',
                  style: ForensicTypography.caption(ColorConstants.forensicGreen),
                ),
                SizedBox(width: ForensicSpacing.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.action.toUpperCase(),
                        style: ForensicTypography.caption(ColorConstants.textPrimary)
                            .copyWith(fontWeight: ForensicTypography.fontWeightBold),
                      ),
                      Text(
                        event.details,
                        style: ForensicTypography.caption(ColorConstants.textSecondary),
                      ),
                      Text(
                        _formatDate(event.timestamp),
                        style: ForensicTypography.caption(ColorConstants.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: ForensicButton(
            label: 'EDIT',
            icon: Icons.edit,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCaseScreen(forensicCase: forensicCase),
                ),
              );
              
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ),
        SizedBox(width: ForensicSpacing.space12),
        Expanded(
          child: ForensicButton(
            label: 'DELETE',
            icon: Icons.delete,
            color: ColorConstants.forensicRed,
            onPressed: () => _handleDelete(context, ref),
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ColorConstants.bgPrimary,
        title: Text(
          '⚠️ CONFIRM DELETION',
          style: ForensicTypography.body(ColorConstants.forensicRed),
        ),
        content: Text(
          'Are you sure you want to delete case ${forensicCase.caseId}? '
          'This action cannot be undone.',
          style: ForensicTypography.caption(ColorConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: ForensicTypography.caption(ColorConstants.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'DELETE',
              style: ForensicTypography.caption(ColorConstants.forensicRed),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await ref
          .read(forensicCaseControllerProvider.notifier)
          .deleteCase(forensicCase.caseId);
      
      if (success && context.mounted) {
        Navigator.pop(context, true);
      }
    }
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
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}
