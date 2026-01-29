import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLogger {
  static Future<void> log({
    required String userId,
    required String action,
    required String details,
  }) async {
    await FirebaseFirestore.instance
        .collection('activity_logs')
        .add({
      'userId': userId,
      'action': action,
      'details': details,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
