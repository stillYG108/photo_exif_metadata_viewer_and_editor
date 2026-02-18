import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../core/theme/forensic_theme.dart';
import '../widgets/tactical_scaffold.dart';
import '../widgets/corner_bracket_container.dart';
import '../widgets/glitch_text.dart';
import '../models/extraction_record.dart';
import '../services/exif_modification_service.dart';

/// EXIF Edit Detail Screen - Edit individual EXIF fields
class ExifEditDetailScreen extends StatefulWidget {
  final ExtractionRecord record;

  const ExifEditDetailScreen({Key? key, required this.record}) : super(key: key);

  @override
  State<ExifEditDetailScreen> createState() => _ExifEditDetailScreenState();
}

class _ExifEditDetailScreenState extends State<ExifEditDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final ExifModificationService _modificationService = ExifModificationService();
  
  // Controllers for editable fields
  final Map<String, TextEditingController> _controllers = {};
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Create controllers for ALL metadata fields dynamically
    widget.record.originalMetadata.forEach((field, value) {
      if (value != null) {
        _controllers[field] = TextEditingController(text: value.toString());
        _controllers[field]!.addListener(() {
          if (!_hasChanges) {
            setState(() => _hasChanges = true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
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
              'METADATA_MODIFICATION',
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
      bottomNavigationBar: _hasChanges ? _buildBottomSaveBar() : null,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Image Preview Header
        _buildImageHeader(),
        
        // Editable Form
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._buildAllFieldsSections(),
                const SizedBox(height: 20), // Reduced padding
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSaveBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: ForensicColors.greenPrimary, width: 2),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: ForensicColors.greenPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PROCESSING...',
                    style: TextStyle(
                      color: ForensicColors.greenPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ],
              )
            : ElevatedButton.icon(
                onPressed: _handleSaveAndDownload,
                icon: Icon(Icons.save, color: Colors.black),
                label: Text(
                  'SAVE & DOWNLOAD',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ForensicColors.greenPrimary,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleSaveAndDownload() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix validation errors', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Collect modified metadata
      final modifiedMetadata = <String, String>{};
      _controllers.forEach((field, controller) {
        if (controller.text.isNotEmpty) {
          modifiedMetadata[field] = controller.text;
        }
      });

      print('=== EXIF EDITOR DEBUG ===');
      print('Image URL: ${widget.record.imageUrl}');
      print('Filename: ${widget.record.imageName}');
      print('Modified fields: ${modifiedMetadata.length}');

      // Modify and download image
      final result = await _modificationService.modifyAndDownloadImage(
        imageUrl: widget.record.imageUrl,
        originalFilename: widget.record.imageName,
        modifiedMetadata: modifiedMetadata,
      );

      if (result['success'] == true) {
        final downloadFolder = result['downloadFolder'] ?? 'Downloads';
        _showSnackBar('✓ Saved to: $downloadFolder\nCheck your Downloads folder!');
        setState(() => _hasChanges = false);
      } else {
        final error = result['error'] ?? 'Unknown error';
        _showSnackBar('✗ Failed: $error', isError: true);
      }
    } catch (e, stackTrace) {
      print('ERROR in _handleSaveAndDownload: $e');
      print('Stack trace: $stackTrace');
      _showSnackBar('✗ Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isError ? ForensicColors.alert : ForensicColors.greenPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: ForensicColors.cyberCyan, width: 2)),
      ),
      child: Stack(
        children: [
          // Background Image
          CachedNetworkImage(
            imageUrl: widget.record.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(color: ForensicColors.cyberCyan),
            ),
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.record.imageName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.record.originalMetadata.length} METADATA FIELDS',
                  style: TextStyle(
                    color: ForensicColors.cyberCyan,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return CornerBracketContainer(
      color: ForensicColors.greenPrimary,
      strokeWidth: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlitchText(
              title,
              style: TextStyle(
                color: ForensicColors.greenPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Build all fields organized by category
  List<Widget> _buildAllFieldsSections() {
    final sections = <Widget>[];
    
    // Categorize fields
    final gpsFields = <String>[];
    final dateFields = <String>[];
    final cameraFields = <String>[];
    final imageFields = <String>[];
    final otherFields = <String>[];
    
    _controllers.keys.forEach((field) {
      final fieldLower = field.toLowerCase();
      if (fieldLower.contains('gps') || fieldLower.contains('latitude') || 
          fieldLower.contains('longitude') || fieldLower.contains('altitude')) {
        gpsFields.add(field);
      } else if (fieldLower.contains('date') || fieldLower.contains('time')) {
        dateFields.add(field);
      } else if (fieldLower.contains('make') || fieldLower.contains('model') || 
                 fieldLower.contains('lens') || fieldLower.contains('camera')) {
        cameraFields.add(field);
      } else if (fieldLower.contains('iso') || fieldLower.contains('fnumber') || 
                 fieldLower.contains('exposure') || fieldLower.contains('focal') ||
                 fieldLower.contains('aperture') || fieldLower.contains('shutter')) {
        imageFields.add(field);
      } else {
        otherFields.add(field);
      }
    });
    
    // Build sections
    if (gpsFields.isNotEmpty) {
      sections.add(_buildSection('GPS COORDINATES', _buildFieldsList(gpsFields)));
      sections.add(const SizedBox(height: 20));
    }
    
    if (dateFields.isNotEmpty) {
      sections.add(_buildSection('DATE & TIME', _buildFieldsList(dateFields)));
      sections.add(const SizedBox(height: 20));
    }
    
    if (cameraFields.isNotEmpty) {
      sections.add(_buildSection('CAMERA INFO', _buildFieldsList(cameraFields)));
      sections.add(const SizedBox(height: 20));
    }
    
    if (imageFields.isNotEmpty) {
      sections.add(_buildSection('IMAGE SETTINGS', _buildFieldsList(imageFields)));
      sections.add(const SizedBox(height: 20));
    }
    
    if (otherFields.isNotEmpty) {
      sections.add(_buildSection('OTHER METADATA (${otherFields.length} fields)', _buildFieldsList(otherFields)));
    }
    
    return sections;
  }
  
  /// Build list of text fields for given field names
  List<Widget> _buildFieldsList(List<String> fields) {
    final widgets = <Widget>[];
    for (var i = 0; i < fields.length; i++) {
      widgets.add(_buildTextField(fields[i], _formatFieldName(fields[i]), 'Enter value'));
      if (i < fields.length - 1) {
        widgets.add(const SizedBox(height: 12));
      }
    }
    return widgets;
  }
  
  /// Format field name for display
  String _formatFieldName(String field) {
    // Convert camelCase or PascalCase to readable format
    return field
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  Widget _buildTextField(String field, String label, String hint) {
    // Skip if controller doesn't exist
    if (!_controllers.containsKey(field)) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ForensicColors.cyberCyan,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controllers[field],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Courier',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.5),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: ForensicColors.greenPrimary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ForensicColors.greenPrimary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ForensicColors.greenPrimary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
