import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_exif/native_exif.dart';

/// Service for modifying EXIF data in images using native_exif
class ExifModificationService {
  /// Download image and embed modified EXIF metadata
  Future<Map<String, dynamic>> modifyAndDownloadImage({
    required String imageUrl,
    required String originalFilename,
    required Map<String, String> modifiedMetadata,
  }) async {
    try {
      // Step 1: Download image from URL
      print('Downloading image from: $imageUrl');
      final imageBytes = await _downloadImage(imageUrl);
      
      // Step 2: Save to temporary file first
      print('Saving to temporary file...');
      final tempFile = await _saveToTempFile(imageBytes, originalFilename);
      
      // Step 3: Modify EXIF data using native_exif
      print('Modifying EXIF data...');
      await _modifyExifData(tempFile.path, modifiedMetadata);
      
      // Step 4: Read modified file
      final modifiedBytes = await tempFile.readAsBytes();
      
      // Step 5: Save to downloads folder
      print('Saving to downloads...');
      final result = await _saveToDownloads(
        modifiedBytes,
        originalFilename,
        modifiedMetadata,
      );
      
      // Clean up temp file
      await tempFile.delete();
      
      return result;
    } catch (e, stackTrace) {
      print('Error in modifyAndDownloadImage: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
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

  /// Save to temporary file for EXIF modification
  Future<File> _saveToTempFile(Uint8List bytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/temp_$filename';
    final file = File(tempPath);
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Modify EXIF data using native_exif package
  Future<void> _modifyExifData(String filePath, Map<String, String> metadata) async {
    try {
      final exif = await Exif.fromPath(filePath);
      
      // Write each metadata field
      for (final entry in metadata.entries) {
        try {
          await exif.writeAttribute(entry.key, entry.value);
          print('✓ Set ${entry.key} = ${entry.value}');
        } catch (e) {
          print('⚠ Could not set ${entry.key}: $e');
        }
      }
      
      // Close the exif object
      await exif.close();
      
      print('✓ EXIF data modified successfully');
    } catch (e) {
      print('Error modifying EXIF: $e');
      throw e;
    }
  }

  /// Save file to downloads folder
  Future<Map<String, dynamic>> _saveToDownloads(
    Uint8List imageBytes,
    String originalFilename,
    Map<String, String> metadata,
  ) async {
    try {
      print('=== SAVE TO DOWNLOADS DEBUG ===');
      print('Platform: ${Platform.operatingSystem}');
      print('Image size: ${imageBytes.length} bytes');
      
      // Request storage permission
      if (Platform.isAndroid) {
        print('Requesting storage permissions...');
        var status = await Permission.storage.request();
        
        if (!status.isGranted) {
          final manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            print('ERROR: Storage permission denied');
            return {'success': false, 'error': 'Storage permission denied'};
          }
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
        print('ERROR: Downloads directory not found');
        return {'success': false, 'error': 'Downloads directory not found'};
      }

      print('Downloads dir: ${downloadsDir.path}');

      // Create filename with _edited suffix
      final nameWithoutExt = originalFilename.replaceAll(RegExp(r'\.[^.]+$'), '');
      final extension = originalFilename.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilename = '${nameWithoutExt}_EXIF_MODIFIED_$timestamp.$extension';
      
      // Save modified image with embedded EXIF data
      final destinationPath = '${downloadsDir.path}/$newFilename';
      print('Saving to: $destinationPath');
      
      final file = File(destinationPath);
      await file.writeAsBytes(imageBytes);
      print('✓ Image saved with modified EXIF data!');
      
      return {
        'success': true,
        'imagePath': destinationPath,
        'downloadFolder': downloadsDir.path,
        'modifiedFields': metadata.length,
      };
    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('Stack: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }
}
