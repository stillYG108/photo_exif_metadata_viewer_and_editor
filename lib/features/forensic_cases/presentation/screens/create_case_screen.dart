import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/forensic_button.dart';
import '../../../../core/widgets/forensic_text_field.dart';
import '../../../../core/widgets/forensic_card.dart';
import '../controllers/forensic_case_controller.dart';
import '../widgets/scanline_overlay.dart';
import '../../domain/entities/forensic_case.dart';

/// Create Case Screen
class CreateCaseScreen extends ConsumerStatefulWidget {
  const CreateCaseScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends ConsumerState<CreateCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  CasePriority _selectedPriority = CasePriority.medium;
  bool _isSubmitting = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScanlineOverlay(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ForensicSpacing.space16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildInstructions(),
                      SizedBox(height: ForensicSpacing.space24),
                      _buildForm(),
                      SizedBox(height: ForensicSpacing.space24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space16),
      decoration: BoxDecoration(
        color: ColorConstants.bgTertiary,
        border: Border(
          top: BorderSide(
            color: ColorConstants.forensicGreen,
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
                    'CREATE NEW CASE',
                    style: ForensicTypography.header2(ColorConstants.textPrimary),
                  ),
                  Text(
                    '> FORENSIC INVESTIGATION INITIATION',
                    style: ForensicTypography.caption(ColorConstants.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstructions() {
    return ForensicCard(
      title: '⚠️ CASE CREATION PROTOCOL',
      borderColor: ColorConstants.forensicAmber,
      child: Text(
        'All fields are required for case initialization. '
        'Case ID will be auto-generated upon submission. '
        'Ensure all information is accurate and complete.',
        style: ForensicTypography.caption(ColorConstants.textSecondary),
      ),
    );
  }
  
  Widget _buildForm() {
    return ForensicCard(
      title: 'CASE INFORMATION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          ForensicTextField(
            label: 'Case Title',
            hint: 'Evidence Analysis - Photo Metadata',
            controller: _titleController,
          ),
          
          SizedBox(height: ForensicSpacing.space16),
          
          // Description
          ForensicTextField(
            label: 'Description',
            hint: 'Detailed case description...',
            controller: _descriptionController,
            maxLines: 4,
          ),
          
          SizedBox(height: ForensicSpacing.space16),
          
          // Priority
          Text(
            '> PRIORITY LEVEL',
            style: ForensicTypography.caption(ColorConstants.textSecondary),
          ),
          SizedBox(height: ForensicSpacing.space8),
          
          Wrap(
            spacing: ForensicSpacing.space8,
            children: CasePriority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              return GestureDetector(
                onTap: () => setState(() => _selectedPriority = priority),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ForensicSpacing.space12,
                    vertical: ForensicSpacing.space8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? ColorConstants.bgTertiary 
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected 
                          ? _getPriorityColor(priority) 
                          : ColorConstants.borderInactive,
                      width: ForensicSpacing.borderMedium,
                    ),
                  ),
                  child: Text(
                    priority.displayName,
                    style: ForensicTypography.caption(
                      isSelected 
                          ? _getPriorityColor(priority) 
                          : ColorConstants.textTertiary,
                    ).copyWith(fontWeight: ForensicTypography.fontWeightBold),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: ForensicSpacing.space16),
          
          // Tags
          ForensicTextField(
            label: 'Tags (comma-separated)',
            hint: 'digital, photo, metadata',
            controller: _tagsController,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ForensicButton(
            label: 'CANCEL',
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            color: ColorConstants.textTertiary,
          ),
        ),
        SizedBox(width: ForensicSpacing.space12),
        Expanded(
          child: ForensicButton(
            label: 'CREATE CASE',
            onPressed: _isSubmitting ? null : _handleSubmit,
            isLoading: _isSubmitting,
            icon: Icons.check,
          ),
        ),
      ],
    );
  }
  
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_titleController.text.trim().isEmpty) {
      _showError('Case title is required');
      return;
    }
    
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Case description is required');
      return;
    }
    
    setState(() => _isSubmitting = true);
    
    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    
    // Create case
    final success = await ref
        .read(forensicCaseControllerProvider.notifier)
        .createCase(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          tags: tags,
        );
    
    setState(() => _isSubmitting = false);
    
    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
        _showSuccess('Case created successfully');
      }
    } else {
      final error = ref.read(forensicCaseControllerProvider).errorMessage;
      _showError(error ?? 'Failed to create case');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '⚠️ ERROR: $message',
          style: ForensicTypography.body(Colors.white),
        ),
        backgroundColor: ColorConstants.forensicRed,
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ SUCCESS: $message',
          style: ForensicTypography.body(Colors.black),
        ),
        backgroundColor: ColorConstants.forensicGreen,
      ),
    );
  }
  
  Color _getPriorityColor(CasePriority priority) {
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
