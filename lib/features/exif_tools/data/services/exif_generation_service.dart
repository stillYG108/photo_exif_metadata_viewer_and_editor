import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exif_data.dart';
import '../datasources/local_image_datasource.dart';

/// EXIF Generation Service
/// Generates EXIF metadata from templates
class ExifGenerationService {
  final LocalImageDatasource _localDatasource;
  final Uuid _uuid = const Uuid();
  
  ExifGenerationService(this._localDatasource);
  
  /// Generate EXIF from template
  Future<File> generateExif({
    required File imageFile,
    required String templateType,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      // Get template data
      final template = _getTemplate(templateType);
      
      // In production, use exiftool to write actual EXIF tags
      // For now, we just save the image
      final modifiedBytes = img.encodeJpg(image);
      final filename = 'generated_${_uuid.v4()}.jpg';
      
      return await _localDatasource.saveImageBytes(modifiedBytes, filename);
    } catch (e) {
      throw ServerException('Failed to generate EXIF: ${e.toString()}');
    }
  }
  
  /// Create EXIF template
  ExifData createTemplate(String templateType) {
    return _getTemplate(templateType);
  }
  
  /// Get predefined template
  ExifData _getTemplate(String templateType) {
    switch (templateType.toLowerCase()) {
      case 'forensic_standard':
        return ExifData(
          make: 'Forensic Camera',
          model: 'FC-2024',
          software: 'EXIF Forensics Workbench v1.0',
          dateTime: DateTime.now(),
          rawData: const {
            'template': 'forensic_standard',
          },
        );
        
      case 'camera_canon':
        return ExifData(
          make: 'Canon',
          model: 'EOS 5D Mark IV',
          software: 'Canon Digital Photo Professional',
          fNumber: 5.6,
          exposureTime: '1/100',
          iso: 400,
          focalLength: 50.0,
          flash: 'Flash did not fire',
          whiteBalance: 'Auto',
          dateTime: DateTime.now(),
          rawData: const {
            'template': 'camera_canon',
          },
        );
        
      case 'camera_nikon':
        return ExifData(
          make: 'NIKON CORPORATION',
          model: 'NIKON D850',
          software: 'Ver.1.00',
          fNumber: 4.0,
          exposureTime: '1/125',
          iso: 200,
          focalLength: 35.0,
          flash: 'Flash did not fire',
          whiteBalance: 'Auto',
          dateTime: DateTime.now(),
          rawData: const {
            'template': 'camera_nikon',
          },
        );
        
      case 'smartphone':
        return ExifData(
          make: 'Apple',
          model: 'iPhone 14 Pro',
          software: 'iOS 17.0',
          latitude: 37.7749,
          longitude: -122.4194,
          dateTime: DateTime.now(),
          rawData: const {
            'template': 'smartphone',
          },
        );
        
      default:
        return ExifData(
          software: 'EXIF Forensics Workbench v1.0',
          dateTime: DateTime.now(),
          rawData: const {
            'template': 'default',
          },
        );
    }
  }
  
  /// Get available templates
  List<String> getAvailableTemplates() {
    return [
      'forensic_standard',
      'camera_canon',
      'camera_nikon',
      'smartphone',
    ];
  }
}
