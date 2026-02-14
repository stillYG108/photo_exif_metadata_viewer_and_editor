/// Forensic Case Status
enum CaseStatus {
  open,
  investigating,
  closed,
  archived;
  
  String get displayName {
    switch (this) {
      case CaseStatus.open:
        return 'OPEN';
      case CaseStatus.investigating:
        return 'INVESTIGATING';
      case CaseStatus.closed:
        return 'CLOSED';
      case CaseStatus.archived:
        return 'ARCHIVED';
    }
  }
  
  static CaseStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return CaseStatus.open;
      case 'investigating':
        return CaseStatus.investigating;
      case 'closed':
        return CaseStatus.closed;
      case 'archived':
        return CaseStatus.archived;
      default:
        return CaseStatus.open;
    }
  }
}

/// Forensic Case Priority
enum CasePriority {
  low,
  medium,
  high,
  critical;
  
  String get displayName {
    switch (this) {
      case CasePriority.low:
        return 'LOW';
      case CasePriority.medium:
        return 'MEDIUM';
      case CasePriority.high:
        return 'HIGH';
      case CasePriority.critical:
        return 'CRITICAL';
    }
  }
  
  static CasePriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return CasePriority.low;
      case 'medium':
        return CasePriority.medium;
      case 'high':
        return CasePriority.high;
      case 'critical':
        return CasePriority.critical;
      default:
        return CasePriority.medium;
    }
  }
}

/// Timeline Event
class TimelineEvent {
  final String action;
  final String userId;
  final DateTime timestamp;
  final String details;
  
  const TimelineEvent({
    required this.action,
    required this.userId,
    required this.timestamp,
    required this.details,
  });
}

/// Forensic Case Entity (Domain Layer)
class ForensicCase {
  final String caseId;
  final String title;
  final String description;
  final String createdBy;
  final String createdByEmail;
  final String? assignedTo;
  final String? assignedToEmail;
  final CaseStatus status;
  final CasePriority priority;
  final int evidenceCount;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final List<TimelineEvent> timeline;
  
  const ForensicCase({
    required this.caseId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdByEmail,
    this.assignedTo,
    this.assignedToEmail,
    required this.status,
    required this.priority,
    this.evidenceCount = 0,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.timeline = const [],
  });
  
  ForensicCase copyWith({
    String? caseId,
    String? title,
    String? description,
    String? createdBy,
    String? createdByEmail,
    String? assignedTo,
    String? assignedToEmail,
    CaseStatus? status,
    CasePriority? priority,
    int? evidenceCount,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    List<TimelineEvent>? timeline,
  }) {
    return ForensicCase(
      caseId: caseId ?? this.caseId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdByEmail: createdByEmail ?? this.createdByEmail,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      timeline: timeline ?? this.timeline,
    );
  }
}
