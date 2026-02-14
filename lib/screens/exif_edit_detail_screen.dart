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

  // Common EXIF fields to edit
  final List<String> _editableFields = [
    'GPSLatitude',
    'GPSLongitude',
    'GPSAltitude',
    'DateTimeOriginal',
    'CreateDate',
    'ModifyDate',
    'Make',
    'Model',
    'LensModel',
    'ISO',
    'FNumber',
    'ExposureTime',
    'FocalLength',
    'Orientation',
    'Software',
    'Copyright',
    'Artist',
    'ImageDescription',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in _editableFields) {
      final value = widget.record.originalMetadata[field]?.toString() ?? '';
      _controllers[field] = TextEditingController(text: value);
      _controllers[field]!.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      title: 'EXIF_EDITOR',
      subtitle: 'METADATA_MODIFICATION',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
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
                    _buildSection('GPS COORDINATES', _buildGPSFields()),
                    const SizedBox(height: 20),
                    _buildSection('DATE & TIME', _buildDateTimeFields()),
                    const SizedBox(height: 20),
                    _buildSection('CAMERA INFO', _buildCameraFields()),
                    const SizedBox(height: 20),
                    _buildSection('IMAGE SETTINGS', _buildImageSettingsFields()),
                    const SizedBox(height: 20),
                    _buildSection('OTHER METADATA', _buildOtherFields()),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Floating Action Button
        if (_hasChanges)
          Positioned(
            bottom: 16,
            right: 16,
            child: _buildSaveButton(),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return CornerBracketContainer(
      color: ForensicColors.greenPrimary,
      strokeWidth: 3,
      child: Material(
        color: Colors.black,
        child: InkWell(
          onTap: _isSaving ? null : _handleSaveAndDownload,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: _isSaving
                ? Row(
                    mainAxisSize: MainAxisSize.min,
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, color: ForensicColors.greenPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SAVE & DOWNLOAD',
                        style: TextStyle(
                          color: ForensicColors.greenPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
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

      // Modify and download image
      final success = await _modificationService.modifyAndDownloadImage(
        imageUrl: widget.record.imageUrl,
        originalFilename: widget.record.imageName,
        modifiedMetadata: modifiedMetadata,
      );

      if (success) {
        _showSnackBar('Image saved successfully with modified EXIF data!');
        setState(() => _hasChanges = false);
      } else {
        _showSnackBar('Failed to save image', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
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

  List<Widget> _buildGPSFields() {
    return [
      _buildTextField('GPSLatitude', 'Latitude', 'e.g., 37.7749'),
      const SizedBox(height: 12),
      _buildTextField('GPSLongitude', 'Longitude', 'e.g., -122.4194'),
      const SizedBox(height: 12),
      _buildTextField('GPSAltitude', 'Altitude (m)', 'e.g., 100'),
    ];
  }

  List<Widget> _buildDateTimeFields() {
    return [
      _buildTextField('DateTimeOriginal', 'Date/Time Original', 'YYYY:MM:DD HH:MM:SS'),
      const SizedBox(height: 12),
      _buildTextField('CreateDate', 'Create Date', 'YYYY:MM:DD HH:MM:SS'),
      const SizedBox(height: 12),
      _buildTextField('ModifyDate', 'Modify Date', 'YYYY:MM:DD HH:MM:SS'),
    ];
  }

  List<Widget> _buildCameraFields() {
    return [
      _buildTextField('Make', 'Camera Make', 'e.g., Canon'),
      const SizedBox(height: 12),
      _buildTextField('Model', 'Camera Model', 'e.g., EOS 5D Mark IV'),
      const SizedBox(height: 12),
      _buildTextField('LensModel', 'Lens Model', 'e.g., EF 24-70mm f/2.8L'),
    ];
  }

  List<Widget> _buildImageSettingsFields() {
    return [
      _buildTextField('ISO', 'ISO', 'e.g., 400'),
      const SizedBox(height: 12),
      _buildTextField('FNumber', 'Aperture (F-Number)', 'e.g., 2.8'),
      const SizedBox(height: 12),
      _buildTextField('ExposureTime', 'Shutter Speed', 'e.g., 1/125'),
      const SizedBox(height: 12),
      _buildTextField('FocalLength', 'Focal Length (mm)', 'e.g., 50'),
    ];
  }

  List<Widget> _buildOtherFields() {
    return [
      _buildTextField('Orientation', 'Orientation', 'e.g., 1'),
      const SizedBox(height: 12),
      _buildTextField('Software', 'Software', 'e.g., Adobe Photoshop'),
      const SizedBox(height: 12),
      _buildTextField('Copyright', 'Copyright', 'e.g., © 2024 Photographer'),
      const SizedBox(height: 12),
      _buildTextField('Artist', 'Artist', 'e.g., John Doe'),
      const SizedBox(height: 12),
      _buildTextField('ImageDescription', 'Description', 'Image description'),
    ];
  }

  Widget _buildTextField(String field, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
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
