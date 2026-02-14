import 'dart:io';
import 'package:exif/exif.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/exif_data.dart';

/// EXIF Parsing Datasource
/// Handles low-level EXIF extraction using exif package
class ExifParsingDatasource {
  /// Extract EXIF data from image file
  Future<ExifData> extractExif(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);
      
      if (data.isEmpty) {
        return const ExifData(
          missingFields: ['All EXIF data missing'],
        );
      }
      
      // Extract standard fields
      final make = data['Image Make']?.printable;
      final model = data['Image Model']?.printable;
      final software = data['Image Software']?.printable;
      
      // Extract GPS data
      final gpsLatRaw = data['GPS GPSLatitude']?.printable;
      final gpsLatRef = data['GPS GPSLatitudeRef']?.printable;
      final gpsLonRaw = data['GPS GPSLongitude']?.printable;
      final gpsLonRef = data['GPS GPSLongitudeRef']?.printable;
      
      // Debug logging
      print('GPS Debug - Latitude: $gpsLatRaw, Ref: $gpsLatRef');
      print('GPS Debug - Longitude: $gpsLonRaw, Ref: $gpsLonRef');
      
      final gpsLat = _parseGPSCoordinate(gpsLatRaw, gpsLatRef ?? 'N');
      final gpsLon = _parseGPSCoordinate(gpsLonRaw, gpsLonRef ?? 'E');
      final gpsAlt = _parseDouble(data['GPS GPSAltitude']?.printable);
      
      // Extract image dimensions
      final width = _parseInt(data['EXIF ExifImageWidth']?.printable) ??
                   _parseInt(data['Image ImageWidth']?.printable);
      final height = _parseInt(data['EXIF ExifImageLength']?.printable) ??
                    _parseInt(data['Image ImageLength']?.printable);
      
      // Extract camera settings
      final orientation = _parseInt(data['Image Orientation']?.printable);
      final fNumber = _parseDouble(data['EXIF FNumber']?.printable);
      final exposureTime = data['EXIF ExposureTime']?.printable;
      final iso = _parseInt(data['EXIF ISOSpeedRatings']?.printable);
      final focalLength = _parseDouble(data['EXIF FocalLength']?.printable);
      final flash = data['EXIF Flash']?.printable;
      final whiteBalance = data['EXIF WhiteBalance']?.printable;
      
      // Extract datetime
      final dateTimeStr = data['EXIF DateTimeOriginal']?.printable ??
                         data['Image DateTime']?.printable;
      final dateTime = _parseDateTime(dateTimeStr);
      
      // Convert all data to map
      final rawData = <String, dynamic>{};
      for (var entry in data.entries) {
        rawData[entry.key] = entry.value.printable;
      }
      
      // Detect missing fields
      final missingFields = _detectMissingFields(data);
      
      // Detect tampered fields
      final tamperedFields = _detectTamperedFields(data);
      
      return ExifData(
        make: make,
        model: model,
        dateTime: dateTime,
        latitude: gpsLat,
        longitude: gpsLon,
        altitude: gpsAlt,
        software: software,
        imageWidth: width,
        imageHeight: height,
        orientation: orientation,
        fNumber: fNumber,
        exposureTime: exposureTime,
        iso: iso,
        focalLength: focalLength,
        flash: flash,
        whiteBalance: whiteBalance,
        rawData: rawData,
        missingFields: missingFields,
        tamperedFields: tamperedFields,
      );
    } catch (e) {
      throw ServerException('Failed to extract EXIF: ${e.toString()}');
    }
  }
  
  /// Parse GPS coordinate from EXIF format
  /// Handles multiple formats:
  /// - [40, 42, 51.39] (degrees, minutes, seconds)
  /// - [40/1, 42/1, 5139/100] (rational format)
  /// - 40.7143 (decimal degrees)
  double? _parseGPSCoordinate(String? coordinate, String? ref) {
    if (coordinate == null) return null;
    
    // If ref is null, we can still try to parse but won't apply direction
    // Default to N for latitude, E for longitude if missing
    
    try {
      // Remove brackets and clean up
      String cleaned = coordinate
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();
      
      // Check if it's already in decimal format (e.g., "40.7143")
      if (!cleaned.contains(',')) {
        final decimal = double.tryParse(cleaned);
        if (decimal != null) {
          // Check if it's zero (invalid GPS)
          if (decimal == 0.0) {
            print('GPS coordinate is zero, skipping');
            return null;
          }
          // Apply reference if available
          if (ref != null && (ref == 'S' || ref == 'W')) {
            return -decimal;
          }
          return decimal;
        }
      }
      
      // Split by comma
      final parts = cleaned.split(',').map((s) => s.trim()).toList();
      
      if (parts.isEmpty || parts.length > 3) return null;
      
      // Parse each part (handle both decimal and rational formats)
      double degrees = 0;
      double minutes = 0;
      double seconds = 0;
      
      // Parse degrees
      if (parts.isNotEmpty) {
        degrees = _parseRationalOrDecimal(parts[0]) ?? 0;
      }
      
      // Parse minutes
      if (parts.length > 1) {
        minutes = _parseRationalOrDecimal(parts[1]) ?? 0;
      }
      
      // Parse seconds
      if (parts.length > 2) {
        seconds = _parseRationalOrDecimal(parts[2]) ?? 0;
      }
      
      // Check if all values are zero (invalid GPS data)
      if (degrees == 0 && minutes == 0 && seconds == 0) {
        print('GPS coordinate is all zeros, skipping');
        return null;
      }
      
      // Convert to decimal degrees
      var decimal = degrees + (minutes / 60) + (seconds / 3600);
      
      // Apply reference (N/S for latitude, E/W for longitude) if available
      if (ref != null && (ref == 'S' || ref == 'W')) {
        decimal = -decimal;
      }
      
      return decimal;
    } catch (e) {
      print('GPS parsing error: $e for coordinate: $coordinate');
      return null;
    }
  }
  
  /// Parse rational (e.g., "40/1") or decimal (e.g., "40.5") number
  double? _parseRationalOrDecimal(String value) {
    if (value.isEmpty) return null;
    
    try {
      // Check if it's a rational number (e.g., "40/1" or "5139/100")
      if (value.contains('/')) {
        final parts = value.split('/');
        if (parts.length == 2) {
          final numerator = double.parse(parts[0].trim());
          final denominator = double.parse(parts[1].trim());
          if (denominator != 0) {
            return numerator / denominator;
          }
        }
        return null;
      }
      
      // Otherwise, parse as decimal
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse integer from EXIF string
  int? _parseInt(String? value) {
    if (value == null) return null;
    try {
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse double from EXIF string
  double? _parseDouble(String? value) {
    if (value == null) return null;
    try {
      // Handle fractions like "5.6" or "1/100"
      if (value.contains('/')) {
        final parts = value.split('/');
        return double.parse(parts[0]) / double.parse(parts[1]);
      }
      return double.parse(value);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse datetime from EXIF string
  DateTime? _parseDateTime(String? value) {
    if (value == null) return null;
    try {
      // Format: "2024:02:12 01:45:00"
      final cleaned = value.replaceAll(':', '-', 0, 2);
      return DateTime.parse(cleaned.replaceFirst(' ', 'T'));
    } catch (e) {
      return null;
    }
  }
  
  /// Detect missing standard EXIF fields
  List<String> _detectMissingFields(Map<String, IfdTag> data) {
    final missing = <String>[];
    
    // Standard fields that should exist
    final standardFields = {
      'Image Make': 'Camera Make',
      'Image Model': 'Camera Model',
      'EXIF DateTimeOriginal': 'Date/Time',
      'Image Software': 'Software',
      'EXIF ExifImageWidth': 'Image Width',
      'EXIF ExifImageLength': 'Image Height',
    };
    
    for (var entry in standardFields.entries) {
      if (!data.containsKey(entry.key)) {
        missing.add(entry.value);
      }
    }
    
    return missing;
  }
  
  /// Detect potentially tampered fields
  List<String> _detectTamperedFields(Map<String, IfdTag> data) {
    final tampered = <String>[];
    
    // Check for suspicious software tags
    final software = data['Image Software']?.printable?.toLowerCase();
    if (software != null) {
      final suspiciousTools = ['photoshop', 'gimp', 'paint.net', 'exiftool'];
      if (suspiciousTools.any((tool) => software.contains(tool))) {
        tampered.add('Software (editing tool detected)');
      }
    }
    
    // Check for missing GPS while having GPS tags
    if (data.containsKey('GPS GPSLatitude') && 
        data['GPS GPSLatitude']?.printable == null) {
      tampered.add('GPS (corrupted data)');
    }
    
    // Check for unrealistic datetime
    final dateTimeStr = data['EXIF DateTimeOriginal']?.printable;
    if (dateTimeStr != null) {
      final dateTime = _parseDateTime(dateTimeStr);
      if (dateTime != null) {
        final now = DateTime.now();
        if (dateTime.isAfter(now)) {
          tampered.add('DateTime (future date)');
        }
        if (dateTime.year < 1990) {
          tampered.add('DateTime (unrealistic date)');
        }
      }
    }
    
    return tampered;
  }
}
