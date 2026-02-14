import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/forensic_case_model.dart';

/// Forensic Case Remote Datasource
/// Handles all Firestore operations for forensic cases
class ForensicCaseRemoteDatasource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  
  ForensicCaseRemoteDatasource({
    required this.firestore,
    required this.auth,
  });
  
  /// Get all cases
  Future<List<ForensicCaseModel>> getCases() async {
    try {
      final snapshot = await firestore
          .collection('forensic_cases')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ForensicCaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch cases: ${e.toString()}');
    }
  }
  
  /// Get cases by status
  Future<List<ForensicCaseModel>> getCasesByStatus(String status) async {
    try {
      final snapshot = await firestore
          .collection('forensic_cases')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ForensicCaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch cases by status: ${e.toString()}');
    }
  }
  
  /// Get case by ID
  Future<ForensicCaseModel> getCaseById(String caseId) async {
    try {
      final doc = await firestore
          .collection('forensic_cases')
          .doc(caseId)
          .get();
      
      if (!doc.exists) {
        throw ServerException('Case not found: $caseId');
      }
      
      return ForensicCaseModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to fetch case: ${e.toString()}');
    }
  }
  
  /// Create new case
  Future<String> createCase(ForensicCaseModel caseModel) async {
    try {
      final docRef = firestore.collection('forensic_cases').doc();
      
      // Generate case ID
      final now = DateTime.now();
      final year = now.year;
      final caseNumber = docRef.id.substring(0, 4).toUpperCase();
      final caseId = 'FC-$year-$caseNumber';
      
      // Create case with generated ID
      final caseWithId = ForensicCaseModel(
        caseId: caseId,
        title: caseModel.title,
        description: caseModel.description,
        createdBy: caseModel.createdBy,
        createdByEmail: caseModel.createdByEmail,
        assignedTo: caseModel.assignedTo,
        assignedToEmail: caseModel.assignedToEmail,
        status: caseModel.status,
        priority: caseModel.priority,
        evidenceCount: caseModel.evidenceCount,
        tags: caseModel.tags,
        createdAt: caseModel.createdAt,
        updatedAt: caseModel.updatedAt,
        timeline: caseModel.timeline,
      );
      
      await docRef.set(caseWithId.toJson());
      
      return caseId;
    } catch (e) {
      throw ServerException('Failed to create case: ${e.toString()}');
    }
  }
  
  /// Update case
  Future<void> updateCase(ForensicCaseModel caseModel) async {
    try {
      final query = await firestore
          .collection('forensic_cases')
          .where('caseId', isEqualTo: caseModel.caseId)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        throw ServerException('Case not found: ${caseModel.caseId}');
      }
      
      await query.docs.first.reference.update(caseModel.toJson());
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update case: ${e.toString()}');
    }
  }
  
  /// Delete case
  Future<void> deleteCase(String caseId) async {
    try {
      final query = await firestore
          .collection('forensic_cases')
          .where('caseId', isEqualTo: caseId)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        throw ServerException('Case not found: $caseId');
      }
      
      await query.docs.first.reference.delete();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete case: ${e.toString()}');
    }
  }
  
  /// Get cases assigned to user
  Future<List<ForensicCaseModel>> getCasesAssignedTo(String userId) async {
    try {
      final snapshot = await firestore
          .collection('forensic_cases')
          .where('assignedTo', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ForensicCaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch assigned cases: ${e.toString()}');
    }
  }
  
  /// Get cases created by user
  Future<List<ForensicCaseModel>> getCasesCreatedBy(String userId) async {
    try {
      final snapshot = await firestore
          .collection('forensic_cases')
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => ForensicCaseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch created cases: ${e.toString()}');
    }
  }
}
