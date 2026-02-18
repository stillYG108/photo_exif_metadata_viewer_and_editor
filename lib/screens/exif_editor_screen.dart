import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/tactical_scaffold.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';
import '../models/extraction_record.dart';
import '../services/forensic_report_service.dart';
import 'exif_edit_detail_screen.dart';

/// EXIF Editor Screen - List all extraction reports with edit functionality
class ExifEditorScreen extends StatefulWidget {
  const ExifEditorScreen({Key? key}) : super(key: key);

  @override
  State<ExifEditorScreen> createState() => _ExifEditorScreenState();
}

class _ExifEditorScreenState extends State<ExifEditorScreen> {
  final ForensicReportService _reportService = ForensicReportService();
  List<ExtractionRecord> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use stream and get first value
      final reportsStream = _reportService.getUserExtractions();
      final reports = await reportsStream.first;
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EXIF_EDITOR',
              style: TextStyle(
                color: ForensicColors.greenPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
            Text(
              'METADATA_MODIFICATION_SYSTEM',
              style: TextStyle(
                color: ForensicColors.cyberCyan,
                fontSize: 10,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: ForensicColors.cyberCyan),
            const SizedBox(height: 16),
            GlitchText(
              'LOADING_REPORTS...',
              style: TextStyle(
                color: ForensicColors.cyberCyan,
                fontSize: 14,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ForensicColors.alert),
            const SizedBox(height: 16),
            Text(
              'ERROR_LOADING_REPORTS',
              style: TextStyle(
                color: ForensicColors.alert,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ForensicColors.cyberCyan,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: ForensicColors.cyberCyan.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'NO_REPORTS_FOUND',
              style: TextStyle(
                color: ForensicColors.cyberCyan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Extract metadata from images first',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReports,
      color: ForensicColors.cyberCyan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (context, index) => _buildReportCard(_reports[index]),
      ),
    );
  }

  Widget _buildReportCard(ExtractionRecord record) {
    final isStripped = record.metadataStatus == 'stripped';
    final statusColor = isStripped ? ForensicColors.alert : ForensicColors.cyberCyan;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
                  border: Border(right: BorderSide(color: statusColor, width: 2)),
                ),
                child: CachedNetworkImage(
                  imageUrl: record.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: ForensicColors.cyberCyan,
                      strokeWidth: 2,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    color: ForensicColors.alert,
                    size: 40,
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
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          record.metadataStatus.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Filename
                      Text(
                        record.imageName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Date
                      Text(
                        dateFormat.format(record.extractedAt),
                        style: TextStyle(
                          color: ForensicColors.cyberCyan,
                          fontSize: 11,
                          fontFamily: 'Courier',
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Metadata count
                      Text(
                        '${record.originalMetadata.length} FIELDS',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Edit Button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleEdit(record),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ForensicColors.greenPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: const RoundedRectangleBorder(),
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'EDIT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
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

  void _handleEdit(ExtractionRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExifEditDetailScreen(record: record),
      ),
    );
  }
}
