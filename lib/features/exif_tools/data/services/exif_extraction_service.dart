import 'dart:io';
import 'package:image/image.dart' as img;
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exif_data.dart';
import '../datasources/local_image_datasource.dart';

/// EXIF Extraction Service
/// Extracts and analyzes EXIF metadata from images
class ExifExtractionService {
  final LocalImageDatasource _localDatasource;
  
  ExifExtractionService(this._localDatasource);
  
  /// Detect missing standard EXIF fields
  Future<List<String>> detectMissingFields(ExifData exifData) async {
    return exifData.missingFields;
  }
  
  /// Detect tampered EXIF fields
  Future<List<String>> detectTamperedFields(ExifData exifData) async {
    return exifData.tamperedFields;
  }
  
  /// Get image dimensions without EXIF
  Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      throw ServerException('Failed to get image dimensions: ${e.toString()}');
    }
  }
  
  /// Validate image file
  Future<bool> validateImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        return false;
      }
      
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      return image != null;
    } catch (e) {
      return false;
    }
  }
  
  /// Get image format
  Future<String> getImageFormat(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      // Check file signature
      if (bytes.length < 4) return 'unknown';
      
      // JPEG: FF D8 FF
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        return 'JPEG';
      }
      
      // PNG: 89 50 4E 47
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && 
          bytes[2] == 0x4E && bytes[3] == 0x47) {
        return 'PNG';
      }
      
      // GIF: 47 49 46
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
        return 'GIF';
      }
      
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
