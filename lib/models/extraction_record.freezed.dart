// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'extraction_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExtractionRecord _$ExtractionRecordFromJson(Map<String, dynamic> json) {
  return _ExtractionRecord.fromJson(json);
}

/// @nodoc
mixin _$ExtractionRecord {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get imageName => throw _privateConstructorUsedError;
  DateTime get extractedAt => throw _privateConstructorUsedError;
  String get metadataStatus =>
      throw _privateConstructorUsedError; // "available", "stripped", "error"
  Map<String, dynamic> get originalMetadata =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> get inferredAnalysis =>
      throw _privateConstructorUsedError;
  Map<String, double> get confidenceScores =>
      throw _privateConstructorUsedError;
  int get processingTimeMs =>
      throw _privateConstructorUsedError; // Additional metadata
  int? get fileSizeBytes => throw _privateConstructorUsedError;
  int? get imageWidth => throw _privateConstructorUsedError;
  int? get imageHeight => throw _privateConstructorUsedError;
  String? get imageFormat => throw _privateConstructorUsedError;

  /// Serializes this ExtractionRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExtractionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExtractionRecordCopyWith<ExtractionRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtractionRecordCopyWith<$Res> {
  factory $ExtractionRecordCopyWith(
    ExtractionRecord value,
    $Res Function(ExtractionRecord) then,
  ) = _$ExtractionRecordCopyWithImpl<$Res, ExtractionRecord>;
  @useResult
  $Res call({
    String id,
    String userId,
    String imageUrl,
    String imageName,
    DateTime extractedAt,
    String metadataStatus,
    Map<String, dynamic> originalMetadata,
    Map<String, dynamic> inferredAnalysis,
    Map<String, double> confidenceScores,
    int processingTimeMs,
    int? fileSizeBytes,
    int? imageWidth,
    int? imageHeight,
    String? imageFormat,
  });
}

/// @nodoc
class _$ExtractionRecordCopyWithImpl<$Res, $Val extends ExtractionRecord>
    implements $ExtractionRecordCopyWith<$Res> {
  _$ExtractionRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExtractionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? imageName = null,
    Object? extractedAt = null,
    Object? metadataStatus = null,
    Object? originalMetadata = null,
    Object? inferredAnalysis = null,
    Object? confidenceScores = null,
    Object? processingTimeMs = null,
    Object? fileSizeBytes = freezed,
    Object? imageWidth = freezed,
    Object? imageHeight = freezed,
    Object? imageFormat = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            imageName: null == imageName
                ? _value.imageName
                : imageName // ignore: cast_nullable_to_non_nullable
                      as String,
            extractedAt: null == extractedAt
                ? _value.extractedAt
                : extractedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            metadataStatus: null == metadataStatus
                ? _value.metadataStatus
                : metadataStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            originalMetadata: null == originalMetadata
                ? _value.originalMetadata
                : originalMetadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            inferredAnalysis: null == inferredAnalysis
                ? _value.inferredAnalysis
                : inferredAnalysis // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            confidenceScores: null == confidenceScores
                ? _value.confidenceScores
                : confidenceScores // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            processingTimeMs: null == processingTimeMs
                ? _value.processingTimeMs
                : processingTimeMs // ignore: cast_nullable_to_non_nullable
                      as int,
            fileSizeBytes: freezed == fileSizeBytes
                ? _value.fileSizeBytes
                : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                      as int?,
            imageWidth: freezed == imageWidth
                ? _value.imageWidth
                : imageWidth // ignore: cast_nullable_to_non_nullable
                      as int?,
            imageHeight: freezed == imageHeight
                ? _value.imageHeight
                : imageHeight // ignore: cast_nullable_to_non_nullable
                      as int?,
            imageFormat: freezed == imageFormat
                ? _value.imageFormat
                : imageFormat // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExtractionRecordImplCopyWith<$Res>
    implements $ExtractionRecordCopyWith<$Res> {
  factory _$$ExtractionRecordImplCopyWith(
    _$ExtractionRecordImpl value,
    $Res Function(_$ExtractionRecordImpl) then,
  ) = __$$ExtractionRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String imageUrl,
    String imageName,
    DateTime extractedAt,
    String metadataStatus,
    Map<String, dynamic> originalMetadata,
    Map<String, dynamic> inferredAnalysis,
    Map<String, double> confidenceScores,
    int processingTimeMs,
    int? fileSizeBytes,
    int? imageWidth,
    int? imageHeight,
    String? imageFormat,
  });
}

/// @nodoc
class __$$ExtractionRecordImplCopyWithImpl<$Res>
    extends _$ExtractionRecordCopyWithImpl<$Res, _$ExtractionRecordImpl>
    implements _$$ExtractionRecordImplCopyWith<$Res> {
  __$$ExtractionRecordImplCopyWithImpl(
    _$ExtractionRecordImpl _value,
    $Res Function(_$ExtractionRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExtractionRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? imageName = null,
    Object? extractedAt = null,
    Object? metadataStatus = null,
    Object? originalMetadata = null,
    Object? inferredAnalysis = null,
    Object? confidenceScores = null,
    Object? processingTimeMs = null,
    Object? fileSizeBytes = freezed,
    Object? imageWidth = freezed,
    Object? imageHeight = freezed,
    Object? imageFormat = freezed,
  }) {
    return _then(
      _$ExtractionRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        imageName: null == imageName
            ? _value.imageName
            : imageName // ignore: cast_nullable_to_non_nullable
                  as String,
        extractedAt: null == extractedAt
            ? _value.extractedAt
            : extractedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        metadataStatus: null == metadataStatus
            ? _value.metadataStatus
            : metadataStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        originalMetadata: null == originalMetadata
            ? _value._originalMetadata
            : originalMetadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        inferredAnalysis: null == inferredAnalysis
            ? _value._inferredAnalysis
            : inferredAnalysis // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        confidenceScores: null == confidenceScores
            ? _value._confidenceScores
            : confidenceScores // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        processingTimeMs: null == processingTimeMs
            ? _value.processingTimeMs
            : processingTimeMs // ignore: cast_nullable_to_non_nullable
                  as int,
        fileSizeBytes: freezed == fileSizeBytes
            ? _value.fileSizeBytes
            : fileSizeBytes // ignore: cast_nullable_to_non_nullable
                  as int?,
        imageWidth: freezed == imageWidth
            ? _value.imageWidth
            : imageWidth // ignore: cast_nullable_to_non_nullable
                  as int?,
        imageHeight: freezed == imageHeight
            ? _value.imageHeight
            : imageHeight // ignore: cast_nullable_to_non_nullable
                  as int?,
        imageFormat: freezed == imageFormat
            ? _value.imageFormat
            : imageFormat // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtractionRecordImpl implements _ExtractionRecord {
  const _$ExtractionRecordImpl({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.imageName,
    required this.extractedAt,
    required this.metadataStatus,
    required final Map<String, dynamic> originalMetadata,
    required final Map<String, dynamic> inferredAnalysis,
    required final Map<String, double> confidenceScores,
    required this.processingTimeMs,
    this.fileSizeBytes,
    this.imageWidth,
    this.imageHeight,
    this.imageFormat,
  }) : _originalMetadata = originalMetadata,
       _inferredAnalysis = inferredAnalysis,
       _confidenceScores = confidenceScores;

  factory _$ExtractionRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtractionRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String imageUrl;
  @override
  final String imageName;
  @override
  final DateTime extractedAt;
  @override
  final String metadataStatus;
  // "available", "stripped", "error"
  final Map<String, dynamic> _originalMetadata;
  // "available", "stripped", "error"
  @override
  Map<String, dynamic> get originalMetadata {
    if (_originalMetadata is EqualUnmodifiableMapView) return _originalMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_originalMetadata);
  }

  final Map<String, dynamic> _inferredAnalysis;
  @override
  Map<String, dynamic> get inferredAnalysis {
    if (_inferredAnalysis is EqualUnmodifiableMapView) return _inferredAnalysis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_inferredAnalysis);
  }

  final Map<String, double> _confidenceScores;
  @override
  Map<String, double> get confidenceScores {
    if (_confidenceScores is EqualUnmodifiableMapView) return _confidenceScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_confidenceScores);
  }

  @override
  final int processingTimeMs;
  // Additional metadata
  @override
  final int? fileSizeBytes;
  @override
  final int? imageWidth;
  @override
  final int? imageHeight;
  @override
  final String? imageFormat;

  @override
  String toString() {
    return 'ExtractionRecord(id: $id, userId: $userId, imageUrl: $imageUrl, imageName: $imageName, extractedAt: $extractedAt, metadataStatus: $metadataStatus, originalMetadata: $originalMetadata, inferredAnalysis: $inferredAnalysis, confidenceScores: $confidenceScores, processingTimeMs: $processingTimeMs, fileSizeBytes: $fileSizeBytes, imageWidth: $imageWidth, imageHeight: $imageHeight, imageFormat: $imageFormat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtractionRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imageName, imageName) ||
                other.imageName == imageName) &&
            (identical(other.extractedAt, extractedAt) ||
                other.extractedAt == extractedAt) &&
            (identical(other.metadataStatus, metadataStatus) ||
                other.metadataStatus == metadataStatus) &&
            const DeepCollectionEquality().equals(
              other._originalMetadata,
              _originalMetadata,
            ) &&
            const DeepCollectionEquality().equals(
              other._inferredAnalysis,
              _inferredAnalysis,
            ) &&
            const DeepCollectionEquality().equals(
              other._confidenceScores,
              _confidenceScores,
            ) &&
            (identical(other.processingTimeMs, processingTimeMs) ||
                other.processingTimeMs == processingTimeMs) &&
            (identical(other.fileSizeBytes, fileSizeBytes) ||
                other.fileSizeBytes == fileSizeBytes) &&
            (identical(other.imageWidth, imageWidth) ||
                other.imageWidth == imageWidth) &&
            (identical(other.imageHeight, imageHeight) ||
                other.imageHeight == imageHeight) &&
            (identical(other.imageFormat, imageFormat) ||
                other.imageFormat == imageFormat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    imageUrl,
    imageName,
    extractedAt,
    metadataStatus,
    const DeepCollectionEquality().hash(_originalMetadata),
    const DeepCollectionEquality().hash(_inferredAnalysis),
    const DeepCollectionEquality().hash(_confidenceScores),
    processingTimeMs,
    fileSizeBytes,
    imageWidth,
    imageHeight,
    imageFormat,
  );

  /// Create a copy of ExtractionRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtractionRecordImplCopyWith<_$ExtractionRecordImpl> get copyWith =>
      __$$ExtractionRecordImplCopyWithImpl<_$ExtractionRecordImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtractionRecordImplToJson(this);
  }
}

abstract class _ExtractionRecord implements ExtractionRecord {
  const factory _ExtractionRecord({
    required final String id,
    required final String userId,
    required final String imageUrl,
    required final String imageName,
    required final DateTime extractedAt,
    required final String metadataStatus,
    required final Map<String, dynamic> originalMetadata,
    required final Map<String, dynamic> inferredAnalysis,
    required final Map<String, double> confidenceScores,
    required final int processingTimeMs,
    final int? fileSizeBytes,
    final int? imageWidth,
    final int? imageHeight,
    final String? imageFormat,
  }) = _$ExtractionRecordImpl;

  factory _ExtractionRecord.fromJson(Map<String, dynamic> json) =
      _$ExtractionRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get imageUrl;
  @override
  String get imageName;
  @override
  DateTime get extractedAt;
  @override
  String get metadataStatus; // "available", "stripped", "error"
  @override
  Map<String, dynamic> get originalMetadata;
  @override
  Map<String, dynamic> get inferredAnalysis;
  @override
  Map<String, double> get confidenceScores;
  @override
  int get processingTimeMs; // Additional metadata
  @override
  int? get fileSizeBytes;
  @override
  int? get imageWidth;
  @override
  int? get imageHeight;
  @override
  String? get imageFormat;

  /// Create a copy of ExtractionRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExtractionRecordImplCopyWith<_$ExtractionRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
