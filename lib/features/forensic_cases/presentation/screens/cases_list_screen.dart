import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/color_constants.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/forensic_button.dart';
import '../../../../core/widgets/forensic_loading_indicator.dart';
import '../../../../core/widgets/forensic_error_widget.dart';
import '../controllers/forensic_case_controller.dart';
import '../widgets/scanline_overlay.dart';
import '../widgets/case_card.dart';
import '../../domain/entities/forensic_case.dart';
import 'create_case_screen.dart';
import 'case_details_screen.dart';

/// Cases List Screen
class CasesListScreen extends ConsumerStatefulWidget {
  const CasesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CasesListScreen> createState() => _CasesListScreenState();
}

class _CasesListScreenState extends ConsumerState<CasesListScreen> {
  CaseStatus? _filterStatus;
  
  @override
  void initState() {
    super.initState();
    // Load cases on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(forensicCaseControllerProvider.notifier).loadCases();
    });
  }

  @override
  Widget build(BuildContext context) {
    final casesState = ref.watch(forensicCaseControllerProvider);
    
    return Scaffold(
      body: ScanlineOverlay(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Filter bar
            _buildFilterBar(),
            
            // Cases list
            Expanded(
              child: _buildCasesList(casesState),
            ),
          ],
        ),
      ),
      
      // Floating action button
      floatingActionButton: _buildFAB(),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space16),
      decoration: BoxDecoration(
        color: ColorConstants.bgTertiary,
        border: Border(
          top: BorderSide(
            color: ColorConstants.forensicRed,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ CLASSIFIED - FORENSIC CASE DATABASE ⚠️',
              style: ForensicTypography.caption(ColorConstants.forensicRed)
                  .copyWith(fontWeight: ForensicTypography.fontWeightBold),
            ),
            SizedBox(height: ForensicSpacing.space8),
            Text(
              'FORENSIC CASE MANAGEMENT',
              style: ForensicTypography.header2(ColorConstants.textPrimary),
            ),
            SizedBox(height: ForensicSpacing.space4),
            Text(
              '> SYSTEM STATUS: OPERATIONAL',
              style: ForensicTypography.caption(ColorConstants.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(ForensicSpacing.space12),
      decoration: BoxDecoration(
        color: ColorConstants.bgSecondary,
        border: Border(
          bottom: BorderSide(
            color: ColorConstants.borderInactive,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '> FILTER:',
            style: ForensicTypography.caption(ColorConstants.textSecondary),
          ),
          SizedBox(width: ForensicSpacing.space8),
          
          _buildFilterChip('ALL', null),
          SizedBox(width: ForensicSpacing.space4),
          _buildFilterChip('OPEN', CaseStatus.open),
          SizedBox(width: ForensicSpacing.space4),
          _buildFilterChip('INVESTIGATING', CaseStatus.investigating),
          SizedBox(width: ForensicSpacing.space4),
          _buildFilterChip('CLOSED', CaseStatus.closed),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, CaseStatus? status) {
    final isSelected = _filterStatus == status;
    
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = status);
        if (status == null) {
          ref.read(forensicCaseControllerProvider.notifier).loadCases();
        } else {
          ref.read(forensicCaseControllerProvider.notifier)
              .loadCasesByStatus(status);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ForensicSpacing.space8,
          vertical: ForensicSpacing.space4,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? ColorConstants.bgTertiary 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? ColorConstants.borderPrimary 
                : ColorConstants.borderInactive,
            width: ForensicSpacing.borderMedium,
          ),
        ),
        child: Text(
          label,
          style: ForensicTypography.caption(
            isSelected 
                ? ColorConstants.textPrimary 
                : ColorConstants.textTertiary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildCasesList(CasesState state) {
    if (state.isLoading) {
      return const Center(
        child: ForensicLoadingIndicator(
          message: 'LOADING CASES...',
        ),
      );
    }
    
    if (state.errorMessage != null) {
      return Center(
        child: ForensicErrorWidget(
          errorMessage: state.errorMessage!,
          onRetry: () {
            ref.read(forensicCaseControllerProvider.notifier).loadCases();
          },
        ),
      );
    }
    
    if (state.cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: ColorConstants.textTertiary,
            ),
            SizedBox(height: ForensicSpacing.space16),
            Text(
              'NO CASES FOUND',
              style: ForensicTypography.body(ColorConstants.textSecondary),
            ),
            SizedBox(height: ForensicSpacing.space8),
            Text(
              '> CREATE A NEW CASE TO BEGIN',
              style: ForensicTypography.caption(ColorConstants.textTertiary),
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(ForensicSpacing.space16),
      itemCount: state.cases.length,
      separatorBuilder: (context, index) => 
          SizedBox(height: ForensicSpacing.space12),
      itemBuilder: (context, index) {
        final forensicCase = state.cases[index];
        return CaseCard(
          forensicCase: forensicCase,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CaseDetailsScreen(forensicCase: forensicCase),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ColorConstants.forensicGreen.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ForensicButton(
        label: 'NEW CASE',
        icon: Icons.add,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateCaseScreen(),
            ),
          );
          
          if (result == true) {
            // Reload cases after creation
            ref.read(forensicCaseControllerProvider.notifier).loadCases();
          }
        },
      ),
    );
  }
}
