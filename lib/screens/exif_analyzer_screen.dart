import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/forensic_theme.dart';
import '../services/resilient_metadata_extractor.dart';
import '../services/forensic_report_service.dart';

class ExifAnalyzerScreen extends StatefulWidget {
  const ExifAnalyzerScreen({super.key});

  @override
  State<ExifAnalyzerScreen> createState() => _ExifAnalyzerScreenState();
}

class _ExifAnalyzerScreenState extends State<ExifAnalyzerScreen> {
  File? _selectedImage;
  MetadataExtractionResult? _extractionResult;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  
  final _extractor = ResilientMetadataExtractor();
  final _reportService = ForensicReportService();

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _extractionResult = null;
      });

      final File imageFile = File(image.path);
      
      // Use resilient metadata extractor
      final result = await _extractor.buildResponse(
        imageFile,
        includeInference: true,
      );

      setState(() {
        _selectedImage = imageFile;
        _extractionResult = result;
        _isLoading = false;
      });

      // Auto-save to Firebase
      await _saveToFirebase(imageFile, result);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _selectedImage = null;
        _extractionResult = null;
        _errorMessage = "OPERATION_FAILED :: ${e.toString().split(':').first}";
      });
    }
  }

  Future<void> _saveToFirebase(File imageFile, MetadataExtractionResult result) async {
    try {
      setState(() => _isSaving = true);

      await _reportService.saveExtraction(
        imageFile: imageFile,
        extractionResult: result,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "✓ EXTRACTION SAVED TO FORENSIC REPORTS",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.greenPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving to Firebase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "⚠ SAVE FAILED: ${e.toString()}",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.alert,
              ),
            ),
            backgroundColor: Colors.black,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ForensicColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield, color: ForensicColors.greenPrimary, size: 16),
            const SizedBox(width: 6),
            Text(
              "EXIF_ANALYZER",
              style: GoogleFonts.orbitron(
                color: ForensicColors.greenPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ForensicColors.greenPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(color: ForensicColors.alert),
              color: ForensicColors.alert.withOpacity(0.1),
            ),
            child: Text(
              "TOP_SECRET",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.alert,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mission Briefing
              _buildMissionBriefing(),
              const SizedBox(height: 20),

              // Upload Button
              _buildUploadButton(),
              const SizedBox(height: 20),

              // Loading
              if (_isLoading) _buildLoadingIndicator(),

              // Error
              if (_errorMessage != null && !_isLoading) _buildErrorMessage(),

              // Image Preview
              if (_selectedImage != null && !_isLoading) ...[
                _buildImagePreview(),
                const SizedBox(height: 20),
              ],

              // Metadata Status Badge
              if (_extractionResult != null && !_isLoading) ...[
                _buildStatusBadge(),
                const SizedBox(height: 16),
              ],

              // Original Metadata
              if (_extractionResult != null && 
                  _extractionResult!.originalMetadata.isNotEmpty && 
                  !_isLoading)
                _buildOriginalMetadata(),

              // Inferred Analysis
              if (_extractionResult != null && 
                  _extractionResult!.inferredAnalysis.isNotEmpty && 
                  !_isLoading)
                _buildInferredAnalysis(),

              // Empty State
              if (_selectedImage == null && !_isLoading && _errorMessage == null)
                _buildEmptyState(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionBriefing() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.alert, width: 2),
        color: Colors.black.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: ForensicColors.alert.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber, color: ForensicColors.alert, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "⚠ CLASSIFIED OPERATION ⚠",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    color: ForensicColors.alert,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Icon(Icons.warning_amber, color: ForensicColors.alert, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: ForensicColors.greenPrimary),
              color: ForensicColors.greenPrimary.withOpacity(0.05),
            ),
            child: Column(
              children: [
                Text(
                  "MISSION: DIGITAL FORENSIC ANALYSIS",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.greenPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "OBJECTIVE: EXTRACT & ANALYZE METADATA",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.textDim,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: ForensicColors.greenPrimary.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _pickImage,
        icon: const Icon(Icons.upload_file, size: 24),
        label: Text(
          _selectedImage == null ? "▶ UPLOAD EVIDENCE FILE" : "▶ CHANGE EVIDENCE",
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(18),
          backgroundColor: ForensicColors.greenPrimary,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.greenPrimary, width: 2),
        color: Colors.black.withOpacity(0.9),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: ForensicColors.greenPrimary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "ANALYZING EVIDENCE...",
            style: GoogleFonts.orbitron(
              color: ForensicColors.greenPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "EXTRACTING METADATA • PARSING GPS • IDENTIFYING DEVICE",
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              color: ForensicColors.textDim,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.alert, width: 2),
        color: ForensicColors.alert.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: ForensicColors.alert, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "OPERATION FAILED",
                  style: GoogleFonts.orbitron(
                    color: ForensicColors.alert,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.alert,
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

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.greenPrimary, width: 2),
        boxShadow: [
          BoxShadow(
            color: ForensicColors.greenPrimary.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: ForensicColors.greenPrimary,
            child: Row(
              children: [
                Icon(Icons.image, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    "▼ EVIDENCE FILE PREVIEW",
                    style: GoogleFonts.orbitron(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Image.file(
            _selectedImage!,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black,
            child: Text(
              "FILE: ${_selectedImage!.path.split('/').last}",
              style: GoogleFonts.shareTechMono(
                color: ForensicColors.greenPrimary,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _extractionResult!.metadataStatus;
    final isStripped = status == 'stripped';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isStripped ? ForensicColors.alert : ForensicColors.greenPrimary,
          width: 2,
        ),
        color: (isStripped ? ForensicColors.alert : ForensicColors.greenPrimary)
            .withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            isStripped ? Icons.warning : Icons.check_circle,
            color: isStripped ? ForensicColors.alert : ForensicColors.greenPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "METADATA STATUS: ${status.toUpperCase()}",
                  style: GoogleFonts.orbitron(
                    color: isStripped ? ForensicColors.alert : ForensicColors.greenPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isStripped 
                      ? "EXIF data stripped • Fallback analysis activated"
                      : "Original EXIF metadata available",
                  style: GoogleFonts.shareTechMono(
                    color: ForensicColors.textDim,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
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
        boxShadow: [
          BoxShadow(
            color: ForensicColors.greenPrimary.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader("ORIGINAL METADATA", Icons.verified, 
              _extractionResult!.originalMetadata.length),
          _buildMetadataList(_extractionResult!.originalMetadata, false),
          _buildSectionFooter(),
        ],
      ),
    );
  }

  Widget _buildInferredAnalysis() {
    final analysis = _extractionResult!.inferredAnalysis;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.alert, width: 3),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: ForensicColors.alert.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader("INFERRED ANALYSIS (FALLBACK)", Icons.analytics, 
              analysis.length, isInferred: true),
          
          // File Properties
          if (analysis['file_properties'] != null)
            _buildSubSection("FILE PROPERTIES", analysis['file_properties']),
          
          // Visual Inference
          if (analysis['visual_inference'] != null)
            _buildSubSection("VISUAL INFERENCE", analysis['visual_inference']),
          
          _buildSectionFooter(isInferred: true),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, int count, {bool isInferred = false}) {
    final color = isInferred ? ForensicColors.alert : ForensicColors.greenPrimary;
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.orbitron(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  "$count FIELDS EXTRACTED",
                  style: GoogleFonts.shareTechMono(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataList(Map<String, dynamic> data, bool isInferred) {
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
          _buildMetadataList(data, true),
        ],
      ),
    );
  }

  Widget _buildSectionFooter({bool isInferred = false}) {
    final color = isInferred ? ForensicColors.alert : ForensicColors.greenPrimary;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(top: BorderSide(color: color, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: color, size: 12),
          const SizedBox(width: 8),
          Text(
            "SECURE :: ${DateTime.now().toIso8601String()} :: ${_extractionResult!.processingTimeMs}ms",
            style: GoogleFonts.shareTechMono(
              color: color,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        border: Border.all(color: ForensicColors.borderDim, width: 2),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 80, color: ForensicColors.textDim),
          const SizedBox(height: 20),
          Text(
            "NO EVIDENCE LOADED",
            style: GoogleFonts.orbitron(
              color: ForensicColors.textDim,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "▶ UPLOAD AN IMAGE FILE TO BEGIN FORENSIC ANALYSIS",
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              color: ForensicColors.textDim,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
