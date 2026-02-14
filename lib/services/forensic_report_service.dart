import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/extraction_record.dart';
import 'resilient_metadata_extractor.dart';
import 'imgbb_service.dart';

/// Service for managing forensic extraction records in Firebase
class ForensicReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _imgbb = ImgBBService();
  final _uuid = const Uuid();

  /// Collection reference for extraction records
  CollectionReference get _extractionsCollection =>
      _firestore.collection('extraction_records');

  /// Save extraction result to Firebase
  Future<ExtractionRecord> saveExtraction({
    required File imageFile,
    required MetadataExtractionResult extractionResult,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique ID
      final recordId = _uuid.v4();
      final imageName = imageFile.path.split('/').last;
      final timestamp = DateTime.now();

      // Upload image to ImgBB (replaces Firebase Storage)
      final imageUrl = await _uploadImageToImgBB(imageFile);

      // Extract file properties for quick access
      final fileProps = extractionResult.inferredAnalysis['file_properties'];
      
      // Create extraction record
      final record = ExtractionRecord(
        id: recordId,
        userId: user.uid,
        imageUrl: imageUrl,
        imageName: imageName,
        extractedAt: timestamp,
        metadataStatus: extractionResult.metadataStatus,
        originalMetadata: extractionResult.originalMetadata,
        inferredAnalysis: extractionResult.inferredAnalysis,
        confidenceScores: extractionResult.confidenceScores,
        processingTimeMs: extractionResult.processingTimeMs,
        fileSizeBytes: fileProps?['file_size_bytes'],
        imageWidth: fileProps?['dimensions']?['width'],
        imageHeight: fileProps?['dimensions']?['height'],
        imageFormat: fileProps?['format'],
      );

      // Save to Firestore
      await _extractionsCollection.doc(recordId).set(record.toJson());

      return record;
    } catch (e) {
      print('Error saving extraction: $e');
      rethrow;
    }
  }

  /// Upload image to ImgBB
  Future<String> _uploadImageToImgBB(File imageFile) async {
    try {
      final imageUrl = await _imgbb.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      rethrow;
    }
  }

  /// Fetch all extraction records for current user
  Stream<List<ExtractionRecord>> getUserExtractions() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _extractionsCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('extractedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return ExtractionRecord.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing extraction record: $e');
          return null;
        }
      }).whereType<ExtractionRecord>().toList();
    });
  }

  /// Get single extraction record by ID
  Future<ExtractionRecord?> getExtraction(String recordId) async {
    try {
      final doc = await _extractionsCollection.doc(recordId).get();
      if (!doc.exists) return null;
      
      return ExtractionRecord.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching extraction: $e');
      return null;
    }
  }

  /// Delete extraction record (Note: ImgBB images cannot be deleted via API)
  Future<void> deleteExtraction(String recordId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Delete Firestore document
      // Note: ImgBB images remain hosted but are no longer referenced
      await _extractionsCollection.doc(recordId).delete();
    } catch (e) {
      print('Error deleting extraction: $e');
      rethrow;
    }
  }

  /// Get extraction count for user
  Future<int> getExtractionCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _extractionsCollection
          .where('userId', isEqualTo: user.uid)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting extraction count: $e');
      return 0;
    }
  }
}
