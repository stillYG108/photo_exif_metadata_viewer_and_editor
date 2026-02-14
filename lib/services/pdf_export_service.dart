import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

import '../models/extraction_record.dart';

/// Service for exporting forensic reports as PDF
class PdfExportService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Generate and save PDF report from ExtractionRecord
  Future<File> generatePdfReport(ExtractionRecord record) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      
      // Get current user info
      final user = _auth.currentUser;
      final username = user?.displayName ?? user?.email ?? 'Unknown User';
      
      // Download image from URL
      final imageBytes = await _downloadImage(record.imageUrl);
      final pdfImage = pw.MemoryImage(imageBytes);

      // Add report page - MultiPage will automatically create as many pages as needed
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          maxPages: 100, // Allow up to 100 pages
          build: (context) => [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 20),

            // Report Metadata
            _buildSection('REPORT INFORMATION', [
              _buildRow('Report ID:', record.id.substring(0, 8)),
              _buildRow('Created By:', username),
              _buildRow('Creation Date:', dateFormat.format(record.extractedAt)),
              _buildRow('Image Name:', record.imageName),
              _buildRow('Processing Time:', '${record.processingTimeMs}ms'),
              _buildRow('Metadata Status:', record.metadataStatus.toUpperCase()),
            ]),
            
            pw.SizedBox(height: 20),

            // Image Section
            _buildSection('EVIDENCE IMAGE', [
              pw.Center(
                child: pw.Container(
                  constraints: const pw.BoxConstraints(maxWidth: 350, maxHeight: 350),
                  child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(height: 10),
              if (record.imageWidth != null && record.imageHeight != null)
                pw.Center(
                  child: pw.Text(
                    'Dimensions: ${record.imageWidth} × ${record.imageHeight}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              if (record.imageFormat != null)
                pw.Center(
                  child: pw.Text(
                    'Format: ${record.imageFormat}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              if (record.fileSizeBytes != null)
                pw.Center(
                  child: pw.Text(
                    'File Size: ${_formatFileSize(record.fileSizeBytes!)}',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
            ]),

            pw.SizedBox(height: 20),

            // Original Metadata - LIMITED to 20 fields
            if (record.originalMetadata.isNotEmpty)
              _buildSection('ORIGINAL EXIF METADATA', 
                _formatMetadataLimited(record.originalMetadata, 20)),

            pw.SizedBox(height: 20),

            // Confidence Scores
            if (record.confidenceScores.isNotEmpty)
              _buildSection('CONFIDENCE SCORES', 
                _formatConfidenceScores(record.confidenceScores)),

            pw.SizedBox(height: 30),

            // Footer
            _buildFooter(),
          ],
        ),
      );

      // Save PDF
      final pdfBytes = await pdf.save();
      final filename = 'forensic_report_${record.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      return await _savePdfToDevice(pdfBytes, filename);
    } catch (e) {
      print('Error generating PDF report: $e');
      rethrow;
    }
  }

  /// Download image from URL
  Future<Uint8List> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading image: $e');
      rethrow;
    }
  }

  /// Save PDF to device
  Future<File> _savePdfToDevice(Uint8List pdfBytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(pdfBytes);
      return file;
    } catch (e) {
      print('Error saving PDF: $e');
      rethrow;
    }
  }

  /// Preview and save PDF
  Future<void> previewAndSavePdf(ExtractionRecord record) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      
      // Get current user info
      final user = _auth.currentUser;
      final username = user?.displayName ?? user?.email ?? 'Unknown User';
      
      // Download image from URL
      final imageBytes = await _downloadImage(record.imageUrl);
      final pdfImage = pw.MemoryImage(imageBytes);

      // Add report page - same as generatePdfReport
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          maxPages: 100, // Allow up to 100 pages
          build: (context) => [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildSection('REPORT INFORMATION', [
              _buildRow('Report ID:', record.id.substring(0, 8)),
              _buildRow('Created By:', username),
              _buildRow('Creation Date:', dateFormat.format(record.extractedAt)),
              _buildRow('Image Name:', record.imageName),
              _buildRow('Processing Time:', '${record.processingTimeMs}ms'),
              _buildRow('Metadata Status:', record.metadataStatus.toUpperCase()),
            ]),
            pw.SizedBox(height: 20),
            _buildSection('EVIDENCE IMAGE', [
              pw.Center(
                child: pw.Container(
                  constraints: const pw.BoxConstraints(maxWidth: 350, maxHeight: 350),
                  child: pw.Image(pdfImage, fit: pw.BoxFit.contain),
                ),
              ),
              pw.SizedBox(height: 10),
              if (record.imageWidth != null && record.imageHeight != null)
                pw.Center(child: pw.Text('Dimensions: ${record.imageWidth} × ${record.imageHeight}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
              if (record.imageFormat != null)
                pw.Center(child: pw.Text('Format: ${record.imageFormat}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
              if (record.fileSizeBytes != null)
                pw.Center(child: pw.Text('File Size: ${_formatFileSize(record.fileSizeBytes!)}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))),
            ]),
            pw.SizedBox(height: 20),
            if (record.originalMetadata.isNotEmpty)
              _buildSection('ORIGINAL EXIF METADATA', _formatMetadataLimited(record.originalMetadata, 20)),
            pw.SizedBox(height: 20),
            if (record.confidenceScores.isNotEmpty)
              _buildSection('CONFIDENCE SCORES', _formatConfidenceScores(record.confidenceScores)),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ],
        ),
      );

      // Show preview and save dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'forensic_report_${record.id}.pdf',
      );
    } catch (e) {
      print('Error previewing PDF: $e');
      rethrow;
    }
  }

  /// Build PDF header with enhanced styling
  pw.Widget _buildHeader() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.grey900, PdfColors.grey800],
        ),
        border: pw.Border.all(color: PdfColors.green700, width: 3),
      ),
      child: pw.Stack(
        children: [
          // Main content
          pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'FORENSIC EXIF ANALYSIS',
                            style: pw.TextStyle(
                              fontSize: 28,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green400,
                              letterSpacing: 2,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'DIGITAL EVIDENCE REPORT',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.grey400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Classification badge
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.red700,
                        border: pw.Border.all(color: PdfColors.red900, width: 2),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'CLASSIFIED',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          pw.Container(
                            margin: const pw.EdgeInsets.only(top: 2),
                            height: 2,
                            width: 60,
                            color: PdfColors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green900,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Text(
                    'EXIF Forensics Workbench • Evidence Analysis Division',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build section with enhanced styling
  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Section header with gradient
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: pw.BoxDecoration(
              gradient: const pw.LinearGradient(
                colors: [PdfColors.green800, PdfColors.green900],
              ),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(3),
                topRight: pw.Radius.circular(3),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 4,
                  height: 16,
                  color: PdfColors.green400,
                  margin: const pw.EdgeInsets.only(right: 10),
                ),
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          // Section content
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.only(
                bottomLeft: pw.Radius.circular(3),
                bottomRight: pw.Radius.circular(3),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Build row with enhanced styling
  pw.Widget _buildRow(String label, String value, {bool alternate = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: pw.BoxDecoration(
        color: alternate ? PdfColors.white : PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 160,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format metadata with alternating backgrounds
  List<pw.Widget> _formatMetadata(Map<String, dynamic> metadata) {
    final widgets = <pw.Widget>[];
    int index = 0;
    
    metadata.forEach((key, value) {
      if (value != null) {
        widgets.add(_buildRow(key, value.toString(), alternate: index % 2 == 1));
        index++;
      }
    });
    
    return widgets.isEmpty 
        ? [pw.Text('No metadata available', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))]
        : widgets;
  }

  /// Format metadata with limit to prevent overflow
  List<pw.Widget> _formatMetadataLimited(Map<String, dynamic> metadata, int limit) {
    final widgets = <pw.Widget>[];
    int count = 0;
    
    for (var entry in metadata.entries) {
      if (count >= limit) break;
      if (entry.value != null) {
        widgets.add(_buildRow(entry.key, entry.value.toString(), alternate: count % 2 == 1));
        count++;
      }
    }
    
    if (metadata.length > limit) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.amber50,
            border: pw.Border.all(color: PdfColors.orange600, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Row(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.orange600,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Text(
                  'i',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Text(
                  '${metadata.length - limit} additional metadata fields not shown to optimize PDF size. View full details in the app.',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey800,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets.isEmpty 
        ? [pw.Text('No metadata available', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))]
        : widgets;
  }

  /// Format analysis data with enhanced styling
  List<pw.Widget> _formatAnalysis(Map<String, dynamic> analysis) {
    final widgets = <pw.Widget>[];
    
    analysis.forEach((category, data) {
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 12),
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: PdfColors.green700, width: 1.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Category badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: pw.BoxDecoration(
                  gradient: const pw.LinearGradient(
                    colors: [PdfColors.green700, PdfColors.green800],
                  ),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                ),
                child: pw.Text(
                  category.toUpperCase(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: PdfColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              // Data
              if (data is Map<String, dynamic>)
                ...data.entries.map((e) => 
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 4,
                          height: 4,
                          margin: const pw.EdgeInsets.only(top: 4, right: 6),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.green600,
                            shape: pw.BoxShape.circle,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: '${e.key}: ',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey800,
                                  ),
                                ),
                                pw.TextSpan(
                                  text: e.value.toString(),
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12),
                  child: pw.Text(data.toString(), style: const pw.TextStyle(fontSize: 10)),
                ),
            ],
          ),
        ),
      );
    });
    
    return widgets.isEmpty 
        ? [pw.Text('No analysis data available', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))]
        : widgets;
  }

  /// Format confidence scores with enhanced visual bars
  List<pw.Widget> _formatConfidenceScores(Map<String, double> scores) {
    final widgets = <pw.Widget>[];
    
    scores.forEach((key, value) {
      final percentage = (value * 100).toStringAsFixed(1);
      final barColor = value > 0.7 ? PdfColors.green600 : (value > 0.4 ? PdfColors.orange600 : PdfColors.red600);
      
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    key,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey900,
                    ),
                  ),
                  pw.Text(
                    '$percentage%',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: barColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                height: 18,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
                ),
                child: pw.Stack(
                  children: [
                    pw.Container(
                      width: value * 450,
                      height: 18,
                      decoration: pw.BoxDecoration(
                        color: barColor,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(9)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
    
    return widgets.isEmpty 
        ? [pw.Text('No confidence scores available', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))]
        : widgets;
  }

  /// Build footer with enhanced styling
  pw.Widget _buildFooter() {
    return pw.Container(
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.grey800, PdfColors.grey900],
        ),
        border: pw.Border.all(color: PdfColors.green700, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EXIF Forensics Workbench',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green400,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey400,
                ),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColors.red700,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
              border: pw.Border.all(color: PdfColors.red900, width: 1),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'CONFIDENTIAL',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1,
                  ),
                ),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 2),
                  height: 1,
                  width: 50,
                  color: PdfColors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  // ========== COMPACT LAYOUT METHODS ==========

  /// Build compact header
  pw.Widget _buildCompactHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey900,
        border: pw.Border.all(color: PdfColors.green, width: 2),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FORENSIC EXIF ANALYSIS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'EXIF Forensics Workbench',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.white),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.red, width: 1),
              color: PdfColors.red,
            ),
            child: pw.Text(
              'CLASSIFIED',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact section
  pw.Widget _buildCompactSection(String title, List<pw.Widget> children) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: PdfColors.grey300,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact row
  pw.Widget _buildCompactRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  /// Build two-column metadata layout
  pw.Widget _buildTwoColumnMetadata(String title, Map<String, dynamic> metadata) {
    final entries = metadata.entries.where((e) => e.value != null).toList();
    final leftColumn = <pw.Widget>[];
    final rightColumn = <pw.Widget>[];

    for (int i = 0; i < entries.length; i++) {
      final widget = pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '${entries[i].key}: ',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
                text: entries[i].value.toString(),
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      );

      if (i % 2 == 0) {
        leftColumn.add(widget);
      } else {
        rightColumn.add(widget);
      }
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: PdfColors.grey300,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: leftColumn)),
                pw.SizedBox(width: 12),
                pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rightColumn)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact analysis
  pw.Widget _buildCompactAnalysis(String title, Map<String, dynamic> analysis) {
    final widgets = <pw.Widget>[];
    
    analysis.forEach((category, data) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                category.toUpperCase(),
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.green900),
              ),
              if (data is Map<String, dynamic>)
                ...data.entries.map((e) => 
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8),
                    child: pw.Text('• ${e.key}: ${e.value}', style: const pw.TextStyle(fontSize: 8)),
                  ),
                )
              else
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(data.toString(), style: const pw.TextStyle(fontSize: 8)),
                ),
            ],
          ),
        ),
      );
    });

    return _buildCompactSection(title, widgets);
  }

  /// Build compact confidence scores
  pw.Widget _buildCompactConfidenceScores(String title, Map<String, double> scores) {
    final widgets = <pw.Widget>[];
    
    scores.forEach((key, value) {
      final percentage = (value * 100).toStringAsFixed(0);
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text(key, style: const pw.TextStyle(fontSize: 8)),
              ),
              pw.Expanded(
                child: pw.Stack(
                  children: [
                    pw.Container(
                      height: 12,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                        color: PdfColors.grey200,
                      ),
                    ),
                    pw.Container(
                      height: 12,
                      width: value * 200,
                      color: value > 0.7 ? PdfColors.green : (value > 0.4 ? PdfColors.orange : PdfColors.red),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 6),
              pw.Text('$percentage%', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
    });

    return _buildCompactSection(title, widgets);
  }

  /// Build compact footer
  pw.Widget _buildCompactFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'EXIF Forensics Workbench',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
              ),
            ],
          ),
          pw.Text(
            'CONFIDENTIAL',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
          ),
        ],
      ),
    );
  }
}
