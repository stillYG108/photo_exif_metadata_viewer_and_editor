/// EXIF Data Entity (Domain Layer)
/// Represents extracted EXIF metadata from an image
class ExifData {
  final String? make;
  final String? model;
  final DateTime? dateTime;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final String? software;
  final int? imageWidth;
  final int? imageHeight;
  final int? orientation;
  final double? fNumber;
  final String? exposureTime;
  final int? iso;
  final double? focalLength;
  final String? flash;
  final String? whiteBalance;
  final Map<String, dynamic> rawData;
  final List<String> missingFields;
  final List<String> tamperedFields;
  
  const ExifData({
    this.make,
    this.model,
    this.dateTime,
    this.latitude,
    this.longitude,
    this.altitude,
    this.software,
    this.imageWidth,
    this.imageHeight,
    this.orientation,
    this.fNumber,
    this.exposureTime,
    this.iso,
    this.focalLength,
    this.flash,
    this.whiteBalance,
    this.rawData = const {},
    this.missingFields = const [],
    this.tamperedFields = const [],
  });
  
  ExifData copyWith({
    String? make,
    String? model,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    double? altitude,
    String? software,
    int? imageWidth,
    int? imageHeight,
    int? orientation,
    double? fNumber,
    String? exposureTime,
    int? iso,
    double? focalLength,
    String? flash,
    String? whiteBalance,
    Map<String, dynamic>? rawData,
    List<String>? missingFields,
    List<String>? tamperedFields,
  }) {
    return ExifData(
      make: make ?? this.make,
      model: model ?? this.model,
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      software: software ?? this.software,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      orientation: orientation ?? this.orientation,
      fNumber: fNumber ?? this.fNumber,
      exposureTime: exposureTime ?? this.exposureTime,
      iso: iso ?? this.iso,
      focalLength: focalLength ?? this.focalLength,
      flash: flash ?? this.flash,
      whiteBalance: whiteBalance ?? this.whiteBalance,
      rawData: rawData ?? this.rawData,
      missingFields: missingFields ?? this.missingFields,
      tamperedFields: tamperedFields ?? this.tamperedFields,
    );
  }
  
  /// Check if EXIF data has GPS coordinates
  bool get hasGPS => latitude != null && longitude != null;
  
  /// Check if EXIF data has camera information
  bool get hasCameraInfo => make != null || model != null;
  
  /// Check if EXIF data has timestamp
  bool get hasTimestamp => dateTime != null;
  
  /// Get GPS coordinates as string
  String get gpsString {
    if (!hasGPS) return 'No GPS data';
    return '${latitude!.toStringAsFixed(6)}°, ${longitude!.toStringAsFixed(6)}°';
  }
  
  /// Get camera info as string
  String get cameraString {
    if (!hasCameraInfo) return 'Unknown camera';
    return '${make ?? 'Unknown'} ${model ?? ''}';
  }
}
