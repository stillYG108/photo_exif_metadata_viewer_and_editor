import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String userId;
  final String action;
  final String details;
  final String level; // INFO, WARN, ERROR, SUCCESS
  final Timestamp createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.details,
    required this.level,
    required this.createdAt,
  });

  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      action: data['action'] ?? '',
      details: data['details'] ?? data['meta']?.toString() ?? '',
      level: data['level'] ?? 'INFO',
      createdAt: data['createdAt'] ?? data['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'action': action,
      'details': details,
      'level': level,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'action': action,
      'details': details,
      'level': level,
      'timestamp': createdAt.toDate().toIso8601String(),
    };
  }
}
