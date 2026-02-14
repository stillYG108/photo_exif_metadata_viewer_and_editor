import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/tactical_scaffold.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';
import '../models/extraction_record.dart';
import '../services/forensic_report_service.dart';
import '../services/pdf_export_service.dart';

class EvidenceExportScreen extends StatefulWidget {
  const EvidenceExportScreen({super.key});

  @override
  State<EvidenceExportScreen> createState() => _EvidenceExportScreenState();
}

class _EvidenceExportScreenState extends State<EvidenceExportScreen> {
  final _reportService = ForensicReportService();
  final _pdfExportService = PdfExportService();
  final Map<String, bool> _exportingStates = {};

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
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

                return _buildExportList(extractions);
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
          bottom: BorderSide(color: ForensicColors.cyberCyan, width: 2),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, 
                    color: ForensicColors.cyberCyan, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlitchText(
                        "EVIDENCE_EXPORT",
                        style: GoogleFonts.orbitron(
                          color: ForensicColors.cyberCyan,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "SECURE_PDF_ARCHIVE",
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
                    border: Border.all(color: ForensicColors.cyberCyan),
                    color: ForensicColors.cyberCyan.withOpacity(0.1),
                  ),
                  child: Text(
                    "AUTHORIZED",
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.cyberCyan,
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

  Widget _buildExportList(List<ExtractionRecord> extractions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: extractions.length,
      itemBuilder: (context, index) {
        return _buildExportCard(extractions[index]);
      },
    );
  }

  Widget _buildExportCard(ExtractionRecord record) {
    final isStripped = record.metadataStatus == 'stripped';
    final statusColor = isStripped ? ForensicColors.alert : ForensicColors.cyberCyan;
    final isExporting = _exportingStates[record.id] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CornerBracketContainer(
        color: statusColor,
        strokeWidth: 2,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
          ),
          child: Row(
            children: [
              // Image Preview
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: statusColor, width: 2),
                  ),
                ),
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

              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              record.metadataStatus.toUpperCase(),
                              style: GoogleFonts.shareTechMono(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.imageName,
                        style: GoogleFonts.shareTechMono(
                          color: ForensicColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: ForensicColors.textDim, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(record.extractedAt),
                            style: GoogleFonts.shareTechMono(
                              color: ForensicColors.textDim,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (record.imageWidth != null && record.imageHeight != null)
                        Row(
                          children: [
                            Icon(Icons.photo_size_select_actual, color: ForensicColors.textDim, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              "${record.imageWidth}×${record.imageHeight}",
                              style: GoogleFonts.shareTechMono(
                                color: ForensicColors.textDim,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Export Button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isExporting ? null : () => _handleExportPdf(record),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: ForensicColors.cyberCyan,
                        side: BorderSide(
                          color: isExporting ? ForensicColors.textDim : ForensicColors.cyberCyan,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      icon: isExporting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: ForensicColors.cyberCyan,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.download, size: 18),
                      label: Text(
                        isExporting ? "EXPORTING..." : "EXPORT_PDF",
                        style: GoogleFonts.shareTechMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle PDF export
  Future<void> _handleExportPdf(ExtractionRecord record) async {
    setState(() {
      _exportingStates[record.id] = true;
    });

    try {
      await _pdfExportService.previewAndSavePdf(record);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: ForensicColors.neonGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'PDF_EXPORTED_SUCCESSFULLY',
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: ForensicColors.neonGreen, width: 2),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: ForensicColors.alert),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'EXPORT_FAILED: ${e.toString()}',
                    style: GoogleFonts.shareTechMono(
                      color: ForensicColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: ForensicColors.alert, width: 2),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exportingStates[record.id] = false;
        });
      }
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: ForensicColors.cyberCyan,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            "LOADING_EVIDENCE_ARCHIVE...",
            style: GoogleFonts.orbitron(
              color: ForensicColors.cyberCyan,
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
            Icon(Icons.inventory_2, size: 100, color: ForensicColors.textDim),
            const SizedBox(height: 24),
            Text(
              "NO_EVIDENCE_FOUND",
              style: GoogleFonts.orbitron(
                color: ForensicColors.textDim,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Analyze images to create exportable evidence",
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
              "ERROR_LOADING_EVIDENCE",
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
