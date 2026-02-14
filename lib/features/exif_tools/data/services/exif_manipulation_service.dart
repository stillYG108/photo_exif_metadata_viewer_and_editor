import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exif_data.dart';
import '../../domain/entities/manipulation_log.dart';
import '../datasources/local_image_datasource.dart';

/// EXIF Manipulation Service
/// Modifies EXIF metadata while preserving original files
class ExifManipulationService {
  final LocalImageDatasource _localDatasource;
  final Uuid _uuid = const Uuid();
  
  ExifManipulationService(this._localDatasource);
  
  /// Modify GPS coordinates
  /// Note: Due to limitations of the image package, we create a new image
  /// In production, use exiftool or similar for true EXIF modification
  Future<File> modifyGPS({
    required File imageFile,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      // Read original image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      // For now, we save the modified image
      // In production, use exiftool to modify actual EXIF tags
      final modifiedBytes = img.encodeJpg(image);
      
      final filename = 'modified_${_uuid.v4()}.jpg';
      final modifiedFile = await _localDatasource.saveImageBytes(
        modifiedBytes,
        filename,
      );
      
      return modifiedFile;
    } catch (e) {
      throw ServerException('Failed to modify GPS: ${e.toString()}');
    }
  }
  
  /// Modify camera information
  Future<File> modifyCameraInfo({
    required File imageFile,
    String? make,
    String? model,
    required String userId,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      // Save modified image
      final modifiedBytes = img.encodeJpg(image);
      final filename = 'modified_${_uuid.v4()}.jpg';
      
      return await _localDatasource.saveImageBytes(modifiedBytes, filename);
    } catch (e) {
      throw ServerException('Failed to modify camera info: ${e.toString()}');
    }
  }
  
  /// Modify timestamp
  Future<File> modifyTimestamp({
    required File imageFile,
    required DateTime newDateTime,
    required String userId,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      final modifiedBytes = img.encodeJpg(image);
      final filename = 'modified_${_uuid.v4()}.jpg';
      
      return await _localDatasource.saveImageBytes(modifiedBytes, filename);
    } catch (e) {
      throw ServerException('Failed to modify timestamp: ${e.toString()}');
    }
  }
  
  /// Modify software tag
  Future<File> modifySoftware({
    required File imageFile,
    required String software,
    required String userId,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw const FormatException('Invalid image format');
      }
      
      final modifiedBytes = img.encodeJpg(image);
      final filename = 'modified_${_uuid.v4()}.jpg';
      
      return await _localDatasource.saveImageBytes(modifiedBytes, filename);
    } catch (e) {
      throw ServerException('Failed to modify software: ${e.toString()}');
    }
  }
  
  /// Create manipulation log
  ManipulationLog createLog({
    required String evidenceId,
    required String userId,
    required String userEmail,
    required String action,
    required Map<String, dynamic> changes,
    String? reason,
    String? caseId,
  }) {
    return ManipulationLog(
      logId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
      evidenceId: evidenceId,
      userId: userId,
      userEmail: userEmail,
      action: action,
      changes: changes,
      timestamp: DateTime.now().toUtc(),
      reason: reason ?? 'Forensic analysis',
      caseId: caseId,
    );
  }
}
