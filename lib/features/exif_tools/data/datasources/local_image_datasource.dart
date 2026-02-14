import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../../core/error/exceptions.dart';

/// Local Image Datasource
/// Handles file system operations for images
class LocalImageDatasource {
  /// Save image to app directory
  Future<File> saveImage(File sourceFile, String filename) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${appDir.path}/forensic_evidence');
      
      // Create directory if it doesn't exist
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }
      
      final targetPath = path.join(evidenceDir.path, filename);
      return await sourceFile.copy(targetPath);
    } catch (e) {
      throw CacheException('Failed to save image: ${e.toString()}');
    }
  }
  
  /// Save image bytes to file
  Future<File> saveImageBytes(List<int> bytes, String filename) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${appDir.path}/forensic_evidence');
      
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }
      
      final targetPath = path.join(evidenceDir.path, filename);
      final file = File(targetPath);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      throw CacheException('Failed to save image bytes: ${e.toString()}');
    }
  }
  
  /// Get evidence directory
  Future<Directory> getEvidenceDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${appDir.path}/forensic_evidence');
      
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }
      
      return evidenceDir;
    } catch (e) {
      throw CacheException('Failed to get evidence directory: ${e.toString()}');
    }
  }
  
  /// Delete image file
  Future<void> deleteImage(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw CacheException('Failed to delete image: ${e.toString()}');
    }
  }
  
  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get file size
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      throw CacheException('Failed to get file size: ${e.toString()}');
    }
  }
}
