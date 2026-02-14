import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/scanning_effect.dart';
import '../widgets/glitch_text.dart';
import '../features/activity/providers/activity_log_provider.dart';
import '../models/activity_log_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(activityLogsStreamProvider);
    final filteredLogs = ref.watch(searchedActivityLogsProvider);
    final selectedLevel = ref.watch(selectedLogLevelProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),

              // Search and Filter Controls
              _buildControls(),
              const SizedBox(height: 16),

              // Logs List
              Expanded(
                child: logsAsync.when(
                  data: (_) => _buildLogsList(filteredLogs),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error.toString()),
                ),
              ),
            ],
          ),
        ),

        // Passive Scanning Overlay
        IgnorePointer(
          child: ScanningEffect(
            isScanning: true,
            scanColor: ForensicColors.neonGreen.withOpacity(0.2),
            child: Container(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlitchText(
          "SYSTEM_AUDIT_LOG",
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ForensicColors.neonGreen,
            letterSpacing: 1.5,
          ),
        ),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ForensicColors.alertRed,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "REC",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.alertRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            border: Border.all(color: ForensicColors.borderDim),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
            style: GoogleFonts.shareTechMono(
              color: ForensicColors.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'SEARCH_LOGS...',
              hintStyle: GoogleFonts.shareTechMono(
                color: ForensicColors.textSecondary,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: ForensicColors.cyberCyan,
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: ForensicColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('ALL', null),
              const SizedBox(width: 8),
              _buildFilterChip('INFO', 'INFO'),
              const SizedBox(width: 8),
              _buildFilterChip('WARN', 'WARN'),
              const SizedBox(width: 8),
              _buildFilterChip('ERROR', 'ERROR'),
              const SizedBox(width: 8),
              _buildFilterChip('SUCCESS', 'SUCCESS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? level) {
    final selectedLevel = ref.watch(selectedLogLevelProvider);
    final isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () {
        ref.read(selectedLogLevelProvider.notifier).state = level;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? _getColorForLevel(level ?? 'INFO').withOpacity(0.2)
              : Colors.black.withOpacity(0.6),
          border: Border.all(
            color: isSelected
                ? _getColorForLevel(level ?? 'INFO')
                : ForensicColors.borderDim,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.shareTechMono(
            color: isSelected
                ? _getColorForLevel(level ?? 'INFO')
                : ForensicColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildLogsList(List<ActivityLog> logs) {
    if (logs.isEmpty) {
      return _buildEmptyState();
    }

    return CornerBracketContainer(
      color: ForensicColors.borderBright,
      strokeWidth: 1,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          border: Border(
            left: BorderSide(color: ForensicColors.borderDim),
            right: BorderSide(color: ForensicColors.borderDim),
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => Divider(
            color: ForensicColors.gridLine,
            height: 24,
          ),
          itemBuilder: (context, index) {
            final log = logs[index];
            return _buildLogItem(log);
          },
        ),
      ),
    );
  }

  Widget _buildLogItem(ActivityLog log) {
    final color = _getColorForLevel(log.level);
    final timestamp = log.createdAt.toDate();
    final timeStr = DateFormat('HH:mm:ss').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            "$timeStr :: ",
            style: GoogleFonts.shareTechMono(
              color: ForensicColors.textSecondary,
              fontSize: 12,
            ),
          ),

          // Level Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.5)),
              color: color.withOpacity(0.1),
            ),
            child: Text(
              log.level,
              style: GoogleFonts.shareTechMono(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Action and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.action,
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (log.details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    log.details,
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return CornerBracketContainer(
      color: ForensicColors.borderBright,
      strokeWidth: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: ForensicColors.neonGreen,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(
              "LOADING_ACTIVITY_LOGS...",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return CornerBracketContainer(
      color: ForensicColors.borderBright,
      strokeWidth: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: ForensicColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "NO_ACTIVITY_LOGS_FOUND",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Perform actions to generate logs",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textSecondary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return CornerBracketContainer(
      color: ForensicColors.alertRed,
      strokeWidth: 1,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: ForensicColors.alertRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              "ERROR_LOADING_LOGS",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.alertRed,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level) {
      case 'WARN':
        return ForensicColors.warningAmber;
      case 'SUCCESS':
        return ForensicColors.neonGreen;
      case 'ERROR':
        return ForensicColors.alertRed;
      default:
        return ForensicColors.cyberCyan;
    }
  }
}
