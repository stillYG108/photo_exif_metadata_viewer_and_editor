import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/image_evidence.dart';
import '../datasources/local_image_datasource.dart';

/// Evidence Export Service
/// Exports forensic evidence as PDF reports
class EvidenceExportService {
  final LocalImageDatasource _localDatasource;
  
  EvidenceExportService(this._localDatasource);
  
  /// Generate PDF forensic report
  Future<File> generatePdfReport(ImageEvidence evidence) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      
      // Add report pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            _buildHeader(),
            pw.SizedBox(height: 20),
            
            // Evidence Information
            _buildSection('EVIDENCE INFORMATION', [
              _buildRow('Evidence ID:', evidence.evidenceId),
              _buildRow('Case ID:', evidence.caseId ?? 'N/A'),
              _buildRow('Analyst:', evidence.userEmail),
              _buildRow('Created:', dateFormat.format(evidence.createdAt)),
              if (evidence.modifiedAt != null)
                _buildRow('Modified:', dateFormat.format(evidence.modifiedAt!)),
            ]),
            
            pw.SizedBox(height: 20),
            
            // Original EXIF Data
            if (evidence.originalExif != null)
              _buildSection('ORIGINAL EXIF DATA', [
                if (evidence.originalExif!.make != null)
                  _buildRow('Make:', evidence.originalExif!.make!),
                if (evidence.originalExif!.model != null)
                  _buildRow('Model:', evidence.originalExif!.model!),
                if (evidence.originalExif!.hasGPS)
                  _buildRow('GPS:', evidence.originalExif!.gpsString),
                if (evidence.originalExif!.dateTime != null)
                  _buildRow('DateTime:', 
                    dateFormat.format(evidence.originalExif!.dateTime!)),
                if (evidence.originalExif!.software != null)
                  _buildRow('Software:', evidence.originalExif!.software!),
              ]),
            
            pw.SizedBox(height: 20),
            
            // Modified EXIF Data
            if (evidence.modifiedExif != null)
              _buildSection('MODIFIED EXIF DATA', [
                if (evidence.modifiedExif!.make != null)
                  _buildRow('Make:', evidence.modifiedExif!.make!),
                if (evidence.modifiedExif!.model != null)
                  _buildRow('Model:', evidence.modifiedExif!.model!),
                if (evidence.modifiedExif!.hasGPS)
                  _buildRow('GPS:', evidence.modifiedExif!.gpsString),
                if (evidence.modifiedExif!.dateTime != null)
                  _buildRow('DateTime:', 
                    dateFormat.format(evidence.modifiedExif!.dateTime!)),
                if (evidence.modifiedExif!.software != null)
                  _buildRow('Software:', evidence.modifiedExif!.software!),
              ]),
            
            pw.SizedBox(height: 20),
            
            // Manipulation History
            if (evidence.manipulationHistory.isNotEmpty)
              _buildSection('CHAIN OF EVIDENCE', 
                evidence.manipulationHistory.map((log) {
                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 8),
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${dateFormat.format(log.timestamp)} - ${log.action}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('By: ${log.userEmail}'),
                        pw.Text('Reason: ${log.reason}'),
                        if (log.changes.isNotEmpty)
                          pw.Text('Changes: ${log.changes}'),
                      ],
                    ),
                  );
                }).toList(),
              ),
            
            pw.SizedBox(height: 20),
            
            // Footer
            _buildFooter(),
          ],
        ),
      );
      
      // Save PDF
      final pdfBytes = await pdf.save();
      final filename = 'evidence_report_${evidence.evidenceId}.pdf';
      
      return await _localDatasource.saveImageBytes(pdfBytes, filename);
    } catch (e) {
      throw ServerException('Failed to generate PDF report: ${e.toString()}');
    }
  }
  
  /// Build report header
  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey900,
        border: pw.Border.all(color: PdfColors.red, width: 3),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FORENSIC EVIDENCE REPORT',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'EXIF Forensics Workbench',
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build section
  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
  
  /// Build row
  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
  
  /// Build footer
  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 2),
        ),
      ),
      child: pw.Text(
        'Generated by EXIF Forensics Workbench - ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
      ),
    );
  }
  
  /// Export original image
  Future<File> exportOriginalImage(ImageEvidence evidence) async {
    try {
      final originalFile = File(evidence.originalPath);
      if (!await originalFile.exists()) {
        throw const CacheException('Original image not found');
      }
      
      final filename = 'original_${evidence.evidenceId}.jpg';
      return await _localDatasource.saveImage(originalFile, filename);
    } catch (e) {
      throw ServerException('Failed to export original image: ${e.toString()}');
    }
  }
  
  /// Export modified image
  Future<File?> exportModifiedImage(ImageEvidence evidence) async {
    try {
      if (evidence.modifiedPath == null) return null;
      
      final modifiedFile = File(evidence.modifiedPath!);
      if (!await modifiedFile.exists()) {
        throw const CacheException('Modified image not found');
      }
      
      final filename = 'modified_${evidence.evidenceId}.jpg';
      return await _localDatasource.saveImage(modifiedFile, filename);
    } catch (e) {
      throw ServerException('Failed to export modified image: ${e.toString()}');
    }
  }
}
