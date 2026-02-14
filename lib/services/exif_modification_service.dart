import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for downloading images (EXIF modification requires external tools)
class ExifModificationService {
  /// Download image with metadata information
  /// Note: Full EXIF writing requires platform-specific tools
  /// For now, this downloads the original image with metadata info in filename
  Future<bool> modifyAndDownloadImage({
    required String imageUrl,
    required String originalFilename,
    required Map<String, String> modifiedMetadata,
  }) async {
    try {
      // Step 1: Download image from URL
      print('Downloading image from: $imageUrl');
      final imageBytes = await _downloadImage(imageUrl);
      
      // Step 2: Save to downloads folder with metadata info
      print('Saving to downloads...');
      final success = await _saveToDownloads(
        imageBytes,
        originalFilename,
        modifiedMetadata,
      );
      
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

  /// Save file to downloads folder
  Future<bool> _saveToDownloads(
    Uint8List imageBytes,
    String originalFilename,
    Map<String, String> metadata,
  ) async {
    try {
      // Request storage permission
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try manageExternalStorage for Android 11+
          final manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            print('Storage permission denied');
            return false;
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
        print('Downloads directory not found');
        return false;
      }

      // Create filename with _edited suffix
      final nameWithoutExt = originalFilename.replaceAll(RegExp(r'\.[^.]+$'), '');
      final extension = originalFilename.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilename = '${nameWithoutExt}_edited_$timestamp.$extension';
      
      // Save image file
      final destinationPath = '${downloadsDir.path}/$newFilename';
      final file = File(destinationPath);
      await file.writeAsBytes(imageBytes);
      
      // Save metadata info as JSON file
      final metadataFilename = '${nameWithoutExt}_metadata_$timestamp.json';
      final metadataPath = '${downloadsDir.path}/$metadataFilename';
      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(_formatMetadataAsJson(metadata));
      
      print('Image saved to: $destinationPath');
      print('Metadata saved to: $metadataPath');
      return true;
    } catch (e) {
      print('Error saving to downloads: $e');
      return false;
    }
  }

  /// Format metadata as JSON string
  String _formatMetadataAsJson(Map<String, String> metadata) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    final entries = metadata.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('  "${entry.key}": "${entry.value}"');
      if (i < entries.length - 1) buffer.write(',');
      buffer.writeln();
    }
    buffer.writeln('}');
    return buffer.toString();
  }
}
