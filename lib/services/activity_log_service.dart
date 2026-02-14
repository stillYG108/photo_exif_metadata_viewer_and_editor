import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/activity_log_model.dart';

class ActivityLogService {
  static final _db = FirebaseFirestore.instance;

  /// Log an activity with level (INFO, WARN, ERROR, SUCCESS)
  static Future<void> log(
    String action, {
    Map<String, dynamic>? meta,
    String level = 'INFO',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('activity_logs').add({
      'userId': user.uid,
      'action': action,
      'details': meta?.toString() ?? '',
      'level': level,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all activity logs for a user in real-time
  static Stream<List<ActivityLog>> streamLogs(String userId) {
    return _db
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc))
            .toList());
  }

  /// Stream activity logs filtered by level
  static Stream<List<ActivityLog>> streamLogsByLevel(
    String userId,
    String level,
  ) {
    return _db
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .where('level', isEqualTo: level)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityLog.fromFirestore(doc))
            .toList());
  }

  /// Fetch paginated logs
  static Future<List<ActivityLog>> fetchLogs({
    required String userId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _db
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ActivityLog.fromFirestore(doc)).toList();
  }

  /// Search logs by action or details
  static Future<List<ActivityLog>> searchLogs(
    String userId,
    String query,
  ) async {
    final snapshot = await _db
        .collection('activity_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final logs = snapshot.docs
        .map((doc) => ActivityLog.fromFirestore(doc))
        .where((log) =>
            log.action.toLowerCase().contains(query.toLowerCase()) ||
            log.details.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return logs;
  }
}
