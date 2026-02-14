/// Manipulation Log Entity (Domain Layer)
/// Records every modification made to EXIF data for forensic integrity
class ManipulationLog {
  final String logId;
  final String evidenceId;
  final String userId;
  final String userEmail;
  final String action;
  final Map<String, dynamic> changes;
  final DateTime timestamp;
  final String reason;
  final String? caseId;
  
  const ManipulationLog({
    required this.logId,
    required this.evidenceId,
    required this.userId,
    required this.userEmail,
    required this.action,
    required this.changes,
    required this.timestamp,
    required this.reason,
    this.caseId,
  });
  
  ManipulationLog copyWith({
    String? logId,
    String? evidenceId,
    String? userId,
    String? userEmail,
    String? action,
    Map<String, dynamic>? changes,
    DateTime? timestamp,
    String? reason,
    String? caseId,
  }) {
    return ManipulationLog(
      logId: logId ?? this.logId,
      evidenceId: evidenceId ?? this.evidenceId,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      action: action ?? this.action,
      changes: changes ?? this.changes,
      timestamp: timestamp ?? this.timestamp,
      reason: reason ?? this.reason,
      caseId: caseId ?? this.caseId,
    );
  }
}

/// Action types for manipulation logs
class ManipulationAction {
  static const String exifExtracted = 'EXIF_EXTRACTED';
  static const String exifModified = 'EXIF_MODIFIED';
  static const String exifGenerated = 'EXIF_GENERATED';
  static const String gpsModified = 'GPS_MODIFIED';
  static const String timestampModified = 'TIMESTAMP_MODIFIED';
  static const String cameraInfoModified = 'CAMERA_INFO_MODIFIED';
  static const String softwareModified = 'SOFTWARE_MODIFIED';
  static const String evidenceExported = 'EVIDENCE_EXPORTED';
}
