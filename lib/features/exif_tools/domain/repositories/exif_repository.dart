import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/exif_data.dart';
import '../entities/image_evidence.dart';
import '../entities/manipulation_log.dart';

/// EXIF Repository Interface (Domain Layer)
abstract class ExifRepository {
  /// Analyze image and extract EXIF data
  Future<Either<Failure, ExifData>> analyzeImage(File imageFile);
  
  /// Modify EXIF GPS coordinates
  Future<Either<Failure, File>> modifyGPS({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? reason,
  });
  
  /// Modify EXIF camera information
  Future<Either<Failure, File>> modifyCameraInfo({
    required File imageFile,
    String? make,
    String? model,
    String? reason,
  });
  
  /// Modify EXIF timestamp
  Future<Either<Failure, File>> modifyTimestamp({
    required File imageFile,
    required DateTime newDateTime,
    String? reason,
  });
  
  /// Modify EXIF software tag
  Future<Either<Failure, File>> modifySoftware({
    required File imageFile,
    required String software,
    String? reason,
  });
  
  /// Generate EXIF from template
  Future<Either<Failure, File>> generateExif({
    required File imageFile,
    required String templateType,
  });
  
  /// Create image evidence record
  Future<Either<Failure, ImageEvidence>> createEvidence({
    required File imageFile,
    String? caseId,
    String? description,
    List<String>? tags,
  });
  
  /// Export evidence as PDF report
  Future<Either<Failure, File>> exportEvidencePdf(ImageEvidence evidence);
  
  /// Log manipulation to Firestore
  Future<Either<Failure, void>> logManipulation(ManipulationLog log);
  
  /// Get manipulation history for evidence
  Future<Either<Failure, List<ManipulationLog>>> getManipulationHistory(
    String evidenceId,
  );
}
