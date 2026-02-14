import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

/// Metadata extraction result model
class MetadataExtractionResult {
  final String metadataStatus; // "available" or "stripped"
  final Map<String, dynamic> originalMetadata;
  final Map<String, dynamic> inferredAnalysis;
  final Map<String, double> confidenceScores;
  final int processingTimeMs;

  MetadataExtractionResult({
    required this.metadataStatus,
    required this.originalMetadata,
    required this.inferredAnalysis,
    required this.confidenceScores,
    required this.processingTimeMs,
  });

  Map<String, dynamic> toJson() => {
        'metadata_status': metadataStatus,
        'original_metadata': originalMetadata,
        'inferred_analysis': inferredAnalysis,
        'confidence_scores': confidenceScores,
        'processing_time_ms': processingTimeMs,
      };
}

/// File properties model
class FileProperties {
  final int fileSizeBytes;
  final int width;
  final int height;
  final String format;
  final String? colorProfile;
  final double? compressionRatio;
  final DateTime? created;
  final DateTime? modified;

  FileProperties({
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.format,
    this.colorProfile,
    this.compressionRatio,
    this.created,
    this.modified,
  });

  Map<String, dynamic> toJson() => {
        'file_size_bytes': fileSizeBytes,
        'dimensions': {'width': width, 'height': height},
        'format': format,
        'color_profile': colorProfile,
        'compression_ratio': compressionRatio,
        'timestamps': {
          'created': created?.toIso8601String(),
          'modified': modified?.toIso8601String(),
        },
      };
}

/// Visual inference result model
class VisualInference {
  final String sceneClassification;
  final List<String> detectedObjects;
  final List<String> detectedText;
  final String brightnessEstimation;
  final List<String> dominantColors;

  VisualInference({
    required this.sceneClassification,
    required this.detectedObjects,
    required this.detectedText,
    required this.brightnessEstimation,
    required this.dominantColors,
  });

  Map<String, dynamic> toJson() => {
        'scene_classification': sceneClassification,
        'detected_objects': detectedObjects,
        'detected_text': detectedText,
        'brightness_estimation': brightnessEstimation,
        'dominant_colors': dominantColors,
      };
}

/// Main service class for resilient metadata extraction
class ResilientMetadataExtractor {
  /// Extract EXIF metadata from image file
  /// Returns null if EXIF is missing or corrupted
  Future<Map<String, dynamic>?> extractExif(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final exifData = await readExifFromBytes(bytes);

      if (exifData.isEmpty) {
        return null;
      }

      // Parse EXIF data into structured format
      final Map<String, dynamic> parsed = {};

      exifData.forEach((key, value) {
        try {
          parsed[key] = value.toString();
        } catch (e) {
          // Skip corrupted tags
          parsed[key] = 'CORRUPTED';
        }
      });

      return parsed;
    } catch (e) {
      // EXIF extraction failed - return null to trigger fallback
      print('EXIF extraction failed: $e');
      return null;
    }
  }

  /// Detect if metadata is missing by scanning image header
  Future<bool> detectMissingMetadata(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Check for EXIF markers in JPEG
      if (bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
        // JPEG file - look for EXIF marker (0xFFE1)
        for (int i = 2; i < bytes.length - 1 && i < 1000; i++) {
          if (bytes[i] == 0xFF && bytes[i + 1] == 0xE1) {
            // EXIF marker found
            return false;
          }
        }
        // No EXIF marker found in JPEG
        return true;
      }

      // For other formats, try to read EXIF
      final exifData = await readExifFromBytes(bytes);
      return exifData.isEmpty;
    } catch (e) {
      // If we can't read the file, assume metadata is missing
      return true;
    }
  }

  /// Extract file-level properties
  Future<FileProperties> fallbackFileAnalysis(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final stat = await imageFile.stat();
      final image = img.decodeImage(bytes);

      // Determine format from file extension
      final extension = imageFile.path.split('.').last.toUpperCase();
      final format = _normalizeFormat(extension);

      // Calculate compression ratio (original vs compressed)
      double? compressionRatio;
      if (image != null) {
        final uncompressedSize = image.width * image.height * 3; // RGB
        compressionRatio = stat.size / uncompressedSize;
      }

      return FileProperties(
        fileSizeBytes: stat.size,
        width: image?.width ?? 0,
        height: image?.height ?? 0,
        format: format,
        colorProfile: _detectColorProfile(bytes),
        compressionRatio: compressionRatio,
        created: stat.changed,
        modified: stat.modified,
      );
    } catch (e) {
      print('File analysis error: $e');
      // Return safe defaults
      return FileProperties(
        fileSizeBytes: 0,
        width: 0,
        height: 0,
        format: 'UNKNOWN',
      );
    }
  }

  /// Run visual inference analysis pipeline
  Future<VisualInference> visualInferencePipeline(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return _getDefaultInference();
      }

      // Scene classification (indoor/outdoor)
      final scene = await _classifyScene(image);

      // Object detection (simplified - would use ML model in production)
      final objects = await _detectObjects(image);

      // OCR text detection (simplified)
      final text = await _detectText(image);

      // Brightness estimation
      final brightness = _estimateBrightness(image);

      // Dominant colors
      final colors = _extractDominantColors(image);

      return VisualInference(
        sceneClassification: scene,
        detectedObjects: objects,
        detectedText: text,
        brightnessEstimation: brightness,
        dominantColors: colors,
      );
    } catch (e) {
      print('Visual inference error: $e');
      return _getDefaultInference();
    }
  }

  /// Build structured response
  Future<MetadataExtractionResult> buildResponse(
    File imageFile, {
    bool includeInference = true,
  }) async {
    final startTime = DateTime.now();

    try {
      // Step 1: Attempt EXIF extraction
      final exifData = await extractExif(imageFile);

      // Step 2: Detect if metadata is missing
      final isStripped = exifData == null || exifData.isEmpty;

      Map<String, dynamic> inferredAnalysis = {};
      Map<String, double> confidenceScores = {};

      // Step 3: Run fallback if stripped
      if (isStripped || includeInference) {
        // Always run file analysis for stripped images
        final fileProps = await fallbackFileAnalysis(imageFile);
        inferredAnalysis['file_properties'] = fileProps.toJson();
        confidenceScores['file_properties'] = 1.0; // High confidence

        // Run visual inference if requested or if stripped
        if (includeInference) {
          final visualInf = await visualInferencePipeline(imageFile);
          inferredAnalysis['visual_inference'] = visualInf.toJson();
          
          // Confidence scores for visual inference
          confidenceScores['scene_classification'] = 0.75;
          confidenceScores['object_detection'] = 0.65;
          confidenceScores['text_detection'] = 0.70;
          confidenceScores['brightness_estimation'] = 0.85;
          confidenceScores['color_analysis'] = 0.90;
        }
      }

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;

      return MetadataExtractionResult(
        metadataStatus: isStripped ? 'stripped' : 'available',
        originalMetadata: exifData ?? {},
        inferredAnalysis: inferredAnalysis,
        confidenceScores: confidenceScores,
        processingTimeMs: processingTime,
      );
    } catch (e) {
      print('Metadata extraction error: $e');
      
      // Return safe defaults - never crash
      final processingTime = DateTime.now().difference(startTime).inMilliseconds;
      
      return MetadataExtractionResult(
        metadataStatus: 'error',
        originalMetadata: {},
        inferredAnalysis: {'error': e.toString()},
        confidenceScores: {},
        processingTimeMs: processingTime,
      );
    }
  }

  // ========== HELPER METHODS ==========

  String _normalizeFormat(String extension) {
    switch (extension.toUpperCase()) {
      case 'JPG':
      case 'JPEG':
        return 'JPEG';
      case 'PNG':
        return 'PNG';
      case 'HEIC':
      case 'HEIF':
        return 'HEIC';
      case 'WEBP':
        return 'WEBP';
      default:
        return extension;
    }
  }

  String? _detectColorProfile(Uint8List bytes) {
    // Simplified color profile detection
    // In production, parse ICC profile from image data
    if (bytes.length > 100) {
      // Look for sRGB marker
      final str = String.fromCharCodes(bytes.take(1000));
      if (str.contains('sRGB')) return 'sRGB';
      if (str.contains('Adobe RGB')) return 'Adobe RGB';
    }
    return 'sRGB'; // Default assumption
  }

  Future<String> _classifyScene(img.Image image) async {
    // Simplified scene classification
    // In production, use TensorFlow Lite or ML Kit
    
    final avgBrightness = _calculateAverageBrightness(image);
    final colorVariance = _calculateColorVariance(image);

    // Simple heuristic
    if (avgBrightness > 150 && colorVariance > 30) {
      return 'outdoor';
    } else if (avgBrightness < 100) {
      return 'indoor_low_light';
    } else {
      return 'indoor';
    }
  }

  Future<List<String>> _detectObjects(img.Image image) async {
    // Simplified object detection
    // In production, use ML Kit Object Detection or TensorFlow
    
    final List<String> objects = [];
    
    // Placeholder logic - would use actual ML model
    final avgBrightness = _calculateAverageBrightness(image);
    
    if (avgBrightness > 100) {
      objects.add('unknown_object_1');
    }
    
    return objects;
  }

  Future<List<String>> _detectText(img.Image image) async {
    // Simplified OCR
    // In production, use ML Kit Text Recognition or Tesseract
    
    // Placeholder - would use actual OCR
    return [];
  }

  String _estimateBrightness(img.Image image) {
    final avgBrightness = _calculateAverageBrightness(image);
    
    if (avgBrightness > 180) {
      return 'very_bright_day';
    } else if (avgBrightness > 120) {
      return 'day';
    } else if (avgBrightness > 60) {
      return 'dusk_dawn';
    } else {
      return 'night';
    }
  }

  List<String> _extractDominantColors(img.Image image) {
    final Map<String, int> colorCounts = {};
    
    // Sample pixels (every 10th pixel for performance)
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Quantize to reduce color space
        final colorKey = _quantizeColor(r, g, b);
        colorCounts[colorKey] = (colorCounts[colorKey] ?? 0) + 1;
      }
    }
    
    // Get top 5 colors
    final sorted = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(5).map((e) => e.key).toList();
  }

  double _calculateAverageBrightness(img.Image image) {
    int totalBrightness = 0;
    int pixelCount = 0;
    
    // Sample every 10th pixel
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;
        totalBrightness += brightness.toInt();
        pixelCount++;
      }
    }
    
    return pixelCount > 0 ? totalBrightness / pixelCount : 0;
  }

  double _calculateColorVariance(img.Image image) {
    final List<double> brightnesses = [];
    
    for (int y = 0; y < image.height; y += 10) {
      for (int x = 0; x < image.width; x += 10) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;
        brightnesses.add(brightness);
      }
    }
    
    if (brightnesses.isEmpty) return 0;
    
    final mean = brightnesses.reduce((a, b) => a + b) / brightnesses.length;
    final variance = brightnesses
        .map((b) => (b - mean) * (b - mean))
        .reduce((a, b) => a + b) / brightnesses.length;
    
    return variance;
  }

  String _quantizeColor(int r, int g, int b) {
    // Quantize to 32 levels per channel
    final qr = (r / 32).floor() * 32;
    final qg = (g / 32).floor() * 32;
    final qb = (b / 32).floor() * 32;
    
    return '#${qr.toRadixString(16).padLeft(2, '0')}'
        '${qg.toRadixString(16).padLeft(2, '0')}'
        '${qb.toRadixString(16).padLeft(2, '0')}';
  }

  VisualInference _getDefaultInference() {
    return VisualInference(
      sceneClassification: 'unknown',
      detectedObjects: [],
      detectedText: [],
      brightnessEstimation: 'unknown',
      dominantColors: [],
    );
  }
}
