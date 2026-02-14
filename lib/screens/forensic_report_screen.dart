import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/forensic_theme.dart';
import '../models/extraction_record.dart';
import '../services/forensic_report_service.dart';
import 'extraction_detail_screen.dart';

class ForensicReportScreen extends StatefulWidget {
  const ForensicReportScreen({super.key});

  @override
  State<ForensicReportScreen> createState() => _ForensicReportScreenState();
}

class _ForensicReportScreenState extends State<ForensicReportScreen> {
  final _reportService = ForensicReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForensicColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<ExtractionRecord>>(
              stream: _reportService.getUserExtractions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final extractions = snapshot.data ?? [];

                if (extractions.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildExtractionGrid(extractions);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, ForensicColors.background],
        ),
        border: Border(
          bottom: BorderSide(color: ForensicColors.greenPrimary, width: 2),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder_special, 
                    color: ForensicColors.greenPrimary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FORENSIC_REPORTS",
                        style: GoogleFonts.orbitron(
                          color: ForensicColors.greenPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "EXTRACTION_ARCHIVE",
                        style: GoogleFonts.shareTechMono(
                          color: ForensicColors.textDim,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: ForensicColors.greenPrimary),
                    color: ForensicColors.greenPrimary.withOpacity(0.1),
                  ),
                  child: Text(
                    "CLASSIFIED",
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.greenPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractionGrid(List<ExtractionRecord> extractions) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: extractions.length,
      itemBuilder: (context, index) {
        return _buildExtractionCard(extractions[index]);
      },
    );
  }

  Widget _buildExtractionCard(ExtractionRecord record) {
    final isStripped = record.metadataStatus == 'stripped';
    final statusColor = isStripped ? ForensicColors.alert : ForensicColors.greenPrimary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExtractionDetailScreen(record: record),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: statusColor, width: 2),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: statusColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isStripped ? Icons.warning : Icons.verified,
                    color: Colors.black,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    record.metadataStatus.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Image Preview
            Expanded(
              child: CachedNetworkImage(
                imageUrl: record.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: ForensicColors.panelBackground,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: statusColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: ForensicColors.panelBackground,
                  child: Icon(Icons.broken_image, color: ForensicColors.textDim),
                ),
              ),
            ),

            // Metadata Summary
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(8),
                color: statusColor.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.imageName,
                      style: GoogleFonts.shareTechMono(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: ForensicColors.textDim, size: 10),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(record.extractedAt),
                            style: GoogleFonts.shareTechMono(
                              color: ForensicColors.textDim,
                              fontSize: 8,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (record.imageWidth != null && record.imageHeight != null)
                      Text(
                        "${record.imageWidth}×${record.imageHeight}",
                        style: GoogleFonts.shareTechMono(
                          color: ForensicColors.textDim,
                          fontSize: 8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ForensicColors.greenPrimary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "LOADING_REPORTS...",
            style: GoogleFonts.orbitron(
              color: ForensicColors.greenPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 100, color: ForensicColors.textDim),
            const SizedBox(height: 24),
            Text(
              "NO_REPORTS_FOUND",
              style: GoogleFonts.orbitron(
                color: ForensicColors.textDim,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Analyze images to create forensic reports",
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textDim,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: ForensicColors.alert),
            const SizedBox(height: 20),
            Text(
              "ERROR_LOADING_REPORTS",
              style: GoogleFonts.orbitron(
                color: ForensicColors.alert,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textDim,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
