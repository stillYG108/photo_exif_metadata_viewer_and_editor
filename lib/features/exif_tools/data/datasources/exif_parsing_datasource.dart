import 'dart:io';
import 'package:exif/exif.dart' hide ExifData;
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
  
  /// Parse GPS coordinate from EXIF format.
  ///
  /// The `exif` package can return GPS values in several forms:
  ///   1. Bracketed rational list : "[40/1, 42/1, 3051/100]"
  ///   2. Bracketed integer list  : "[40, 42, 51]"
  ///   3. Space-separated values  : "40/1 42/1 3051/100"
  ///   4. Plain decimal           : "40.7143"
  ///   5. Plain rational          : "40/1"
  ///
  /// Returns null when the coordinate cannot be parsed or is all-zero.
  double? _parseGPSCoordinate(String? coordinate, String? ref) {
    if (coordinate == null || coordinate.trim().isEmpty) return null;

    try {
      // ── Step 1: Strip brackets / parentheses and normalise delimiters ──
      String cleaned = coordinate
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .trim();

      // Replace spaces used as separators with commas so we have one code path
      // e.g. "40/1 42/1 3051/100" → "40/1,42/1,3051/100"
      // But keep spaces that are inside rational pairs intact → won't happen.
      // Use regex: replace one-or-more spaces/commas with a single comma.
      cleaned = cleaned.replaceAll(RegExp(r'[,\s]+'), ',');

      // ── Step 2: Try single decimal (no comma) ──────────────────────────
      if (!cleaned.contains(',')) {
        // Could be a rational like "40/1" or a decimal like "40.7143"
        final value = _parseRationalOrDecimal(cleaned);
        if (value == null) return null;
        if (value == 0.0) {
          print('GPS coordinate is zero (single value), treating as N/A');
          return null;
        }
        return (ref == 'S' || ref == 'W') ? -value : value;
      }

      // ── Step 3: Split into DMS components ─────────────────────────────
      final parts = cleaned.split(',').map((s) => s.trim()).toList();

      // Must have 1–3 parts (degrees, optional minutes, optional seconds)
      if (parts.isEmpty || parts.length > 3) return null;

      final degrees = _parseRationalOrDecimal(parts[0]) ?? 0.0;
      final minutes = parts.length > 1 ? (_parseRationalOrDecimal(parts[1]) ?? 0.0) : 0.0;
      final seconds = parts.length > 2 ? (_parseRationalOrDecimal(parts[2]) ?? 0.0) : 0.0;

      // All-zero means no GPS lock — treat as unavailable
      if (degrees == 0.0 && minutes == 0.0 && seconds == 0.0) {
        print('GPS DMS is all zeros — no GPS lock, treating as N/A');
        return null;
      }

      // ── Step 4: Convert DMS → decimal degrees ─────────────────────────
      double decimal = degrees + (minutes / 60.0) + (seconds / 3600.0);

      // Apply hemisphere reference
      if (ref == 'S' || ref == 'W') decimal = -decimal;

      print('GPS parsed: $degrees° $minutes\' $seconds" $ref → $decimal');
      return decimal;
    } catch (e) {
      print('GPS parsing error: $e for coordinate: "$coordinate"');
      return null;
    }
  }

  /// Parse a rational string like "40/1" or a plain decimal like "40.5".
  /// Returns null if value is empty, malformed, or has a zero denominator.
  double? _parseRationalOrDecimal(String value) {
    final v = value.trim();
    if (v.isEmpty) return null;

    try {
      if (v.contains('/')) {
        final parts = v.split('/');
        if (parts.length != 2) return null;
        final numerator   = double.tryParse(parts[0].trim());
        final denominator = double.tryParse(parts[1].trim());
        if (numerator == null || denominator == null || denominator == 0) {
          return null;
        }
        return numerator / denominator;
      }
      return double.tryParse(v);
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
  
  /// Parse datetime from EXIF string.
  /// EXIF format: "2024:02:12 01:45:00"  (colons in date part).
  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      // Replace first two colons (date separators) with dashes, then the space with T
      // e.g. "2024:02:12 01:45:00" → "2024-02-12T01:45:00"
      final parts = value.trim().split(' ');
      if (parts.length < 2) return null;
      final datePart = parts[0].replaceAll(':', '-');  // "2024-02-12"
      final timePart = parts[1];                        // "01:45:00"
      return DateTime.parse('${datePart}T$timePart');
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
