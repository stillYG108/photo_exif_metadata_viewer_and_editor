import 'package:freezed_annotation/freezed_annotation.dart';

part 'extraction_record.freezed.dart';
part 'extraction_record.g.dart';

/// Model for storing EXIF extraction records in Firebase
@freezed
class ExtractionRecord with _$ExtractionRecord {
  const factory ExtractionRecord({
    required String id,
    required String userId,
    required String imageUrl,
    required String imageName,
    required DateTime extractedAt,
    required String metadataStatus, // "available", "stripped", "error"
    required Map<String, dynamic> originalMetadata,
    required Map<String, dynamic> inferredAnalysis,
    required Map<String, double> confidenceScores,
    required int processingTimeMs,
    
    // Additional metadata
    int? fileSizeBytes,
    int? imageWidth,
    int? imageHeight,
    String? imageFormat,
  }) = _ExtractionRecord;

  factory ExtractionRecord.fromJson(Map<String, dynamic> json) =>
      _$ExtractionRecordFromJson(json);
}
