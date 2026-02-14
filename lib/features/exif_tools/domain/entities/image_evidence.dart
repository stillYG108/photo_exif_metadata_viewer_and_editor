import 'exif_data.dart';
import 'manipulation_log.dart';

/// Image Evidence Entity (Domain Layer)
/// Represents a forensic image evidence with original and modified versions
class ImageEvidence {
  final String evidenceId;
  final String originalPath;
  final String? modifiedPath;
  final ExifData? originalExif;
  final ExifData? modifiedExif;
  final String? caseId;
  final String userId;
  final String userEmail;
  final DateTime createdAt;
  final DateTime? modifiedAt;
  final List<ManipulationLog> manipulationHistory;
  final String? description;
  final List<String> tags;
  
  const ImageEvidence({
    required this.evidenceId,
    required this.originalPath,
    this.modifiedPath,
    this.originalExif,
    this.modifiedExif,
    this.caseId,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    this.modifiedAt,
    this.manipulationHistory = const [],
    this.description,
    this.tags = const [],
  });
  
  ImageEvidence copyWith({
    String? evidenceId,
    String? originalPath,
    String? modifiedPath,
    ExifData? originalExif,
    ExifData? modifiedExif,
    String? caseId,
    String? userId,
    String? userEmail,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<ManipulationLog>? manipulationHistory,
    String? description,
    List<String>? tags,
  }) {
    return ImageEvidence(
      evidenceId: evidenceId ?? this.evidenceId,
      originalPath: originalPath ?? this.originalPath,
      modifiedPath: modifiedPath ?? this.modifiedPath,
      originalExif: originalExif ?? this.originalExif,
      modifiedExif: modifiedExif ?? this.modifiedExif,
      caseId: caseId ?? this.caseId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      manipulationHistory: manipulationHistory ?? this.manipulationHistory,
      description: description ?? this.description,
      tags: tags ?? this.tags,
    );
  }
  
  /// Check if evidence has been modified
  bool get isModified => modifiedPath != null;
  
  /// Get number of modifications
  int get modificationCount => manipulationHistory.length;
  
  /// Check if evidence is linked to a case
  bool get isLinkedToCase => caseId != null;
}
