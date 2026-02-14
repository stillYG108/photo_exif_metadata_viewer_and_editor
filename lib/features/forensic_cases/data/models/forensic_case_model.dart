import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/forensic_case.dart';

/// Forensic Case Model (Data Layer)
/// Handles JSON serialization/deserialization for Firestore
class ForensicCaseModel extends ForensicCase {
  const ForensicCaseModel({
    required super.caseId,
    required super.title,
    required super.description,
    required super.createdBy,
    required super.createdByEmail,
    super.assignedTo,
    super.assignedToEmail,
    required super.status,
    required super.priority,
    super.evidenceCount,
    required super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.closedAt,
    super.timeline,
  });
  
  /// Create model from Firestore document
  factory ForensicCaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ForensicCaseModel(
      caseId: data['caseId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      createdBy: data['createdBy'] as String,
      createdByEmail: data['createdByEmail'] as String,
      assignedTo: data['assignedTo'] as String?,
      assignedToEmail: data['assignedToEmail'] as String?,
      status: CaseStatus.fromString(data['status'] as String),
      priority: CasePriority.fromString(data['priority'] as String),
      evidenceCount: data['evidenceCount'] as int? ?? 0,
      tags: List<String>.from(data['tags'] as List),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      closedAt: data['closedAt'] != null 
          ? (data['closedAt'] as Timestamp).toDate() 
          : null,
      timeline: _parseTimeline(data['timeline'] as List?),
    );
  }
  
  /// Create model from JSON map
  factory ForensicCaseModel.fromJson(Map<String, dynamic> json) {
    return ForensicCaseModel(
      caseId: json['caseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      createdByEmail: json['createdByEmail'] as String,
      assignedTo: json['assignedTo'] as String?,
      assignedToEmail: json['assignedToEmail'] as String?,
      status: CaseStatus.fromString(json['status'] as String),
      priority: CasePriority.fromString(json['priority'] as String),
      evidenceCount: json['evidenceCount'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      closedAt: json['closedAt'] != null 
          ? DateTime.parse(json['closedAt'] as String) 
          : null,
      timeline: _parseTimeline(json['timeline'] as List?),
    );
  }
  
  /// Convert to JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
      'assignedTo': assignedTo,
      'assignedToEmail': assignedToEmail,
      'status': status.name,
      'priority': priority.name,
      'evidenceCount': evidenceCount,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'timeline': timeline.map((e) => {
        'action': e.action,
        'userId': e.userId,
        'timestamp': Timestamp.fromDate(e.timestamp),
        'details': e.details,
      }).toList(),
    };
  }
  
  /// Convert from domain entity
  factory ForensicCaseModel.fromEntity(ForensicCase entity) {
    return ForensicCaseModel(
      caseId: entity.caseId,
      title: entity.title,
      description: entity.description,
      createdBy: entity.createdBy,
      createdByEmail: entity.createdByEmail,
      assignedTo: entity.assignedTo,
      assignedToEmail: entity.assignedToEmail,
      status: entity.status,
      priority: entity.priority,
      evidenceCount: entity.evidenceCount,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      closedAt: entity.closedAt,
      timeline: entity.timeline,
    );
  }
  
  /// Parse timeline from Firestore data
  static List<TimelineEvent> _parseTimeline(List? timelineData) {
    if (timelineData == null) return [];
    
    return timelineData.map((event) {
      final eventMap = event as Map<String, dynamic>;
      return TimelineEvent(
        action: eventMap['action'] as String,
        userId: eventMap['userId'] as String,
        timestamp: (eventMap['timestamp'] as Timestamp).toDate(),
        details: eventMap['details'] as String,
      );
    }).toList();
  }
}
