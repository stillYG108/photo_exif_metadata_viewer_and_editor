import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String userId;
  final String action;
  final String details;
  final Timestamp createdAt;

  ActivityLog({
    required this.userId,
    required this.action,
    required this.details,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'action': action,
      'details': details,
      'createdAt': createdAt,
    };
  }
}
