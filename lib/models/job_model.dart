import 'package:cloud_firestore/cloud_firestore.dart';

class ForensicJob {
  final String jobId;
  final String userId;
  final String serviceId;
  final String status;
  final String inputFile;
  final String? outputFile;
  final Timestamp createdAt;
  final Timestamp? completedAt;

  ForensicJob({
    required this.jobId,
    required this.userId,
    required this.serviceId,
    required this.status,
    required this.inputFile,
    this.outputFile,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'status': status,
      'inputFile': inputFile,
      'outputFile': outputFile,
      'createdAt': createdAt,
      'completedAt': completedAt,
    };
  }
}
