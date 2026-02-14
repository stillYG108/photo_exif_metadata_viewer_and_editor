import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/manipulation_log.dart';

/// Firestore Logging Datasource
/// Handles logging of all EXIF manipulations to Firestore
class FirestoreLoggingDatasource {
  final FirebaseFirestore _firestore;
  
  FirestoreLoggingDatasource(this._firestore);
  
  /// Log manipulation to Firestore
  Future<void> logManipulation(ManipulationLog log) async {
    try {
      await _firestore
          .collection('manipulation_logs')
          .doc(log.logId)
          .set({
        'logId': log.logId,
        'evidenceId': log.evidenceId,
        'userId': log.userId,
        'userEmail': log.userEmail,
        'action': log.action,
        'changes': log.changes,
        'timestamp': Timestamp.fromDate(log.timestamp),
        'reason': log.reason,
        'caseId': log.caseId,
      });
    } catch (e) {
      throw ServerException('Failed to log manipulation: ${e.toString()}');
    }
  }
  
  /// Get manipulation history for evidence
  Future<List<ManipulationLog>> getManipulationHistory(String evidenceId) async {
    try {
      final snapshot = await _firestore
          .collection('manipulation_logs')
          .where('evidenceId', isEqualTo: evidenceId)
          .orderBy('timestamp', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ManipulationLog(
          logId: data['logId'] as String,
          evidenceId: data['evidenceId'] as String,
          userId: data['userId'] as String,
          userEmail: data['userEmail'] as String,
          action: data['action'] as String,
          changes: Map<String, dynamic>.from(data['changes'] as Map),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          reason: data['reason'] as String,
          caseId: data['caseId'] as String?,
        );
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get manipulation history: ${e.toString()}');
    }
  }
  
  /// Log activity (for activity_logs collection)
  Future<void> logActivity({
    required String userId,
    required String userEmail,
    required String action,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'userEmail': userEmail,
        'action': action,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException('Failed to log activity: ${e.toString()}');
    }
  }
}
