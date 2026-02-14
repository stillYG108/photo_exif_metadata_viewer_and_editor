import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../core/theme/forensic_theme.dart';
import '../models/extraction_record.dart';

class ExtractionDetailScreen extends StatelessWidget {
  final ExtractionRecord record;

  const ExtractionDetailScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final isStripped = record.metadataStatus == 'stripped';
    final statusColor = isStripped ? ForensicColors.alert : ForensicColors.greenPrimary;

    return Scaffold(
      backgroundColor: ForensicColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, color: statusColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "EXTRACTION_REPORT",
                style: GoogleFonts.orbitron(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: statusColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, ForensicColors.background],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Badge
              _buildStatusBadge(statusColor, isStripped),
              const SizedBox(height: 16),

              // Image Display
              _buildImageDisplay(),
              const SizedBox(height: 16),

              // File Info
              _buildFileInfo(),
              const SizedBox(height: 16),

              // Original Metadata
              if (record.originalMetadata.isNotEmpty)
                _buildOriginalMetadata(),

              // Inferred Analysis
              if (record.inferredAnalysis.isNotEmpty)
                _buildInferredAnalysis(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Color statusColor, bool isStripped) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor, width: 2),
        color: statusColor.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            isStripped ? Icons.warning : Icons.check_circle,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "STATUS: ${record.metadataStatus.toUpperCase()}",
                  style: GoogleFonts.orbitron(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isStripped
                      ? "EXIF stripped • Fallback analysis used"
                      : "Original EXIF metadata extracted",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.textDim,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.greenPrimary, width: 3),
        boxShadow: [
          BoxShadow(
            color: ForensicColors.greenPrimary.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: ForensicColors.greenPrimary,
            child: Row(
              children: [
                Icon(Icons.image, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "▼ EVIDENCE IMAGE",
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: record.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            placeholder: (_, __) => Container(
              height: 300,
              color: ForensicColors.panelBackground,
              child: Center(
                child: CircularProgressIndicator(
                  color: ForensicColors.greenPrimary,
                ),
              ),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 300,
              color: ForensicColors.panelBackground,
              child: Icon(Icons.broken_image, size: 80, color: ForensicColors.textDim),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.greenPrimary),
        color: Colors.black,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FILE INFORMATION",
            style: GoogleFonts.orbitron(
              color: ForensicColors.greenPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow("FILENAME", record.imageName),
          _buildInfoRow("EXTRACTED", _formatDate(record.extractedAt)),
          _buildInfoRow("PROCESSING_TIME", "${record.processingTimeMs}ms"),
          if (record.imageWidth != null && record.imageHeight != null)
            _buildInfoRow("DIMENSIONS", "${record.imageWidth}×${record.imageHeight}"),
          if (record.fileSizeBytes != null)
            _buildInfoRow("SIZE", _formatBytes(record.fileSizeBytes!)),
          if (record.imageFormat != null)
            _buildInfoRow("FORMAT", record.imageFormat!),
        ],
      ),
    );
  }

  Widget _buildOriginalMetadata() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.greenPrimary, width: 3),
        color: Colors.black,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ForensicColors.greenPrimary, ForensicColors.greenPrimary.withOpacity(0.7)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "ORIGINAL METADATA",
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildMetadataList(record.originalMetadata),
        ],
      ),
    );
  }

  Widget _buildInferredAnalysis() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.alert, width: 3),
        color: Colors.black,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ForensicColors.alert, ForensicColors.alert.withOpacity(0.7)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Colors.black, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "INFERRED ANALYSIS",
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (record.inferredAnalysis['file_properties'] != null)
            _buildSubSection("FILE PROPERTIES", record.inferredAnalysis['file_properties']),
          if (record.inferredAnalysis['visual_inference'] != null)
            _buildSubSection("VISUAL INFERENCE", record.inferredAnalysis['visual_inference']),
        ],
      ),
    );
  }

  Widget _buildMetadataList(Map<String, dynamic> data) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.keys.length,
      separatorBuilder: (_, __) => Divider(
        color: ForensicColors.greenPrimary.withOpacity(0.3),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final key = data.keys.elementAt(index);
        final value = data[key];

        return Container(
          padding: const EdgeInsets.all(14),
          color: index % 2 == 0
              ? Colors.black
              : ForensicColors.greenPrimary.withOpacity(0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "▸ $key",
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.greenPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value.toString(),
                style: GoogleFonts.shareTechMono(
                  color: ForensicColors.textPrimary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubSection(String title, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.alert.withOpacity(0.5)),
        color: ForensicColors.alert.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: ForensicColors.alert.withOpacity(0.2),
            child: Text(
              "► $title",
              style: GoogleFonts.orbitron(
                color: ForensicColors.alert,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          _buildMetadataList(data),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$label:",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.greenPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.textPrimary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
        "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }
}
