import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:native_exif/native_exif.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for modifying EXIF data and downloading images
class ExifModificationService {
  /// Modify EXIF data and download image with new metadata
  Future<bool> modifyAndDownloadImage({
    required String imageUrl,
    required String originalFilename,
    required Map<String, String> modifiedMetadata,
  }) async {
    try {
      // Step 1: Download image from URL
      print('Downloading image from: $imageUrl');
      final imageBytes = await _downloadImage(imageUrl);
      
      // Step 2: Save to temporary file
      final tempFile = await _saveToTempFile(imageBytes, originalFilename);
      
      // Step 3: Modify EXIF data
      print('Modifying EXIF data...');
      await _modifyExifData(tempFile, modifiedMetadata);
      
      // Step 4: Save to downloads folder
      print('Saving to downloads...');
      final success = await _saveToDownloads(tempFile, originalFilename);
      
      // Step 5: Clean up temp file
      await tempFile.delete();
      
      return success;
    } catch (e) {
      print('Error in modifyAndDownloadImage: $e');
      return false;
    }
  }

  /// Download image from URL
  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image: ${response.statusCode}');
    }
  }

  /// Save bytes to temporary file
  Future<File> _saveToTempFile(Uint8List bytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$filename');
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  /// Modify EXIF data using native_exif package
  Future<void> _modifyExifData(File imageFile, Map<String, String> metadata) async {
    final exif = await Exif.fromPath(imageFile.path);
    
    try {
      // Apply each metadata field
      for (final entry in metadata.entries) {
        await _setExifAttribute(exif, entry.key, entry.value);
      }
      
      // Close the exif file
      await exif.close();
    } catch (e) {
      print('Error modifying EXIF: $e');
      await exif.close();
      rethrow;
    }
  }

  /// Set individual EXIF attribute
  Future<void> _setExifAttribute(Exif exif, String key, String value) async {
    try {
      // Map common EXIF fields to native_exif attributes
      switch (key) {
        case 'GPSLatitude':
          await exif.writeAttribute('GPSLatitude', value);
          break;
        case 'GPSLongitude':
          await exif.writeAttribute('GPSLongitude', value);
          break;
        case 'GPSAltitude':
          await exif.writeAttribute('GPSAltitude', value);
          break;
        case 'DateTimeOriginal':
          await exif.writeAttribute('DateTimeOriginal', value);
          break;
        case 'CreateDate':
          await exif.writeAttribute('CreateDate', value);
          break;
        case 'ModifyDate':
          await exif.writeAttribute('DateTime', value);
          break;
        case 'Make':
          await exif.writeAttribute('Make', value);
          break;
        case 'Model':
          await exif.writeAttribute('Model', value);
          break;
        case 'LensModel':
          await exif.writeAttribute('LensModel', value);
          break;
        case 'ISO':
          await exif.writeAttribute('ISOSpeedRatings', value);
          break;
        case 'FNumber':
          await exif.writeAttribute('FNumber', value);
          break;
        case 'ExposureTime':
          await exif.writeAttribute('ExposureTime', value);
          break;
        case 'FocalLength':
          await exif.writeAttribute('FocalLength', value);
          break;
        case 'Orientation':
          await exif.writeAttribute('Orientation', value);
          break;
        case 'Software':
          await exif.writeAttribute('Software', value);
          break;
        case 'Copyright':
          await exif.writeAttribute('Copyright', value);
          break;
        case 'Artist':
          await exif.writeAttribute('Artist', value);
          break;
        case 'ImageDescription':
          await exif.writeAttribute('ImageDescription', value);
          break;
        default:
          // Try to set it anyway
          await exif.writeAttribute(key, value);
      }
    } catch (e) {
      print('Warning: Could not set $key: $e');
    }
  }

  /// Save file to downloads folder
  Future<bool> _saveToDownloads(File sourceFile, String originalFilename) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          print('Storage permission denied');
          return false;
        }
      }

      // Get downloads directory
      Directory? downloadsDir;
      
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        downloadsDir = Directory('$userProfile\\Downloads');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        print('Downloads directory not found');
        return false;
      }

      // Create filename with _edited suffix
      final nameWithoutExt = originalFilename.replaceAll(RegExp(r'\.[^.]+$'), '');
      final extension = originalFilename.split('.').last;
      final newFilename = '${nameWithoutExt}_edited.$extension';
      
      // Copy file to downloads
      final destinationPath = '${downloadsDir.path}/$newFilename';
      await sourceFile.copy(destinationPath);
      
      print('File saved to: $destinationPath');
      return true;
    } catch (e) {
      print('Error saving to downloads: $e');
      return false;
    }
  }
}
