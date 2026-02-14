// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'extraction_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExtractionRecordImpl _$$ExtractionRecordImplFromJson(
  Map<String, dynamic> json,
) => _$ExtractionRecordImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  imageUrl: json['imageUrl'] as String,
  imageName: json['imageName'] as String,
  extractedAt: DateTime.parse(json['extractedAt'] as String),
  metadataStatus: json['metadataStatus'] as String,
  originalMetadata: json['originalMetadata'] as Map<String, dynamic>,
  inferredAnalysis: json['inferredAnalysis'] as Map<String, dynamic>,
  confidenceScores: (json['confidenceScores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  processingTimeMs: (json['processingTimeMs'] as num).toInt(),
  fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt(),
  imageWidth: (json['imageWidth'] as num?)?.toInt(),
  imageHeight: (json['imageHeight'] as num?)?.toInt(),
  imageFormat: json['imageFormat'] as String?,
);

Map<String, dynamic> _$$ExtractionRecordImplToJson(
  _$ExtractionRecordImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'imageUrl': instance.imageUrl,
  'imageName': instance.imageName,
  'extractedAt': instance.extractedAt.toIso8601String(),
  'metadataStatus': instance.metadataStatus,
  'originalMetadata': instance.originalMetadata,
  'inferredAnalysis': instance.inferredAnalysis,
  'confidenceScores': instance.confidenceScores,
  'processingTimeMs': instance.processingTimeMs,
  'fileSizeBytes': instance.fileSizeBytes,
  'imageWidth': instance.imageWidth,
  'imageHeight': instance.imageHeight,
  'imageFormat': instance.imageFormat,
};
