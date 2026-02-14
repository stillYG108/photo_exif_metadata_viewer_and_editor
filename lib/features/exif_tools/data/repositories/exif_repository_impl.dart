import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/exif_data.dart';
import '../../domain/entities/image_evidence.dart';
import '../../domain/entities/manipulation_log.dart';
import '../../domain/repositories/exif_repository.dart';
import '../datasources/exif_parsing_datasource.dart';
import '../datasources/local_image_datasource.dart';
import '../datasources/firestore_logging_datasource.dart';
import '../services/exif_extraction_service.dart';
import '../services/exif_manipulation_service.dart';
import '../services/exif_generation_service.dart';
import '../services/evidence_export_service.dart';

/// EXIF Repository Implementation
class ExifRepositoryImpl implements ExifRepository {
  final ExifParsingDatasource _exifParsingDatasource;
  final LocalImageDatasource _localImageDatasource;
  final FirestoreLoggingDatasource _firestoreLoggingDatasource;
  final ExifExtractionService _extractionService;
  final ExifManipulationService _manipulationService;
  final ExifGenerationService _generationService;
  final EvidenceExportService _exportService;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();
  
  ExifRepositoryImpl({
    required ExifParsingDatasource exifParsingDatasource,
    required LocalImageDatasource localImageDatasource,
    required FirestoreLoggingDatasource firestoreLoggingDatasource,
    required ExifExtractionService extractionService,
    required ExifManipulationService manipulationService,
    required ExifGenerationService generationService,
    required EvidenceExportService exportService,
    required FirebaseAuth auth,
  })  : _exifParsingDatasource = exifParsingDatasource,
        _localImageDatasource = localImageDatasource,
        _firestoreLoggingDatasource = firestoreLoggingDatasource,
        _extractionService = extractionService,
        _manipulationService = manipulationService,
        _generationService = generationService,
        _exportService = exportService,
        _auth = auth;
  
  @override
  Future<Either<Failure, ExifData>> analyzeImage(File imageFile) async {
    try {
      // Validate image
      final isValid = await _extractionService.validateImageFile(imageFile);
      if (!isValid) {
        return const Left(ValidationFailure('Invalid image file'));
      }
      
      // Extract EXIF
      final exifData = await _exifParsingDatasource.extractExif(imageFile);
      
      // Log activity
      final user = _auth.currentUser;
      if (user != null) {
        await _firestoreLoggingDatasource.logActivity(
          userId: user.uid,
          userEmail: user.email ?? 'unknown',
          action: 'EXIF_ANALYZED',
          details: {
            'hasGPS': exifData.hasGPS,
            'hasCameraInfo': exifData.hasCameraInfo,
            'missingFieldsCount': exifData.missingFields.length,
            'tamperedFieldsCount': exifData.tamperedFields.length,
          },
        );
      }
      
      return Right(exifData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> modifyGPS({
    required File imageFile,
    required double latitude,
    required double longitude,
    String? reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      // Modify GPS
      final modifiedFile = await _manipulationService.modifyGPS(
        imageFile: imageFile,
        latitude: latitude,
        longitude: longitude,
        userId: user.uid,
      );
      
      // Create manipulation log
      final log = _manipulationService.createLog(
        evidenceId: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.gpsModified,
        changes: {
          'latitude': latitude,
          'longitude': longitude,
        },
        reason: reason,
      );
      
      // Log to Firestore
      await _firestoreLoggingDatasource.logManipulation(log);
      
      // Log activity
      await _firestoreLoggingDatasource.logActivity(
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: 'GPS_MODIFIED',
        details: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      
      return Right(modifiedFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> modifyCameraInfo({
    required File imageFile,
    String? make,
    String? model,
    String? reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      final modifiedFile = await _manipulationService.modifyCameraInfo(
        imageFile: imageFile,
        make: make,
        model: model,
        userId: user.uid,
      );
      
      final log = _manipulationService.createLog(
        evidenceId: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.cameraInfoModified,
        changes: {
          'make': make,
          'model': model,
        },
        reason: reason,
      );
      
      await _firestoreLoggingDatasource.logManipulation(log);
      
      return Right(modifiedFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> modifyTimestamp({
    required File imageFile,
    required DateTime newDateTime,
    String? reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      final modifiedFile = await _manipulationService.modifyTimestamp(
        imageFile: imageFile,
        newDateTime: newDateTime,
        userId: user.uid,
      );
      
      final log = _manipulationService.createLog(
        evidenceId: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.timestampModified,
        changes: {
          'newDateTime': newDateTime.toIso8601String(),
        },
        reason: reason,
      );
      
      await _firestoreLoggingDatasource.logManipulation(log);
      
      return Right(modifiedFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> modifySoftware({
    required File imageFile,
    required String software,
    String? reason,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      final modifiedFile = await _manipulationService.modifySoftware(
        imageFile: imageFile,
        software: software,
        userId: user.uid,
      );
      
      final log = _manipulationService.createLog(
        evidenceId: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.softwareModified,
        changes: {
          'software': software,
        },
        reason: reason,
      );
      
      await _firestoreLoggingDatasource.logManipulation(log);
      
      return Right(modifiedFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> generateExif({
    required File imageFile,
    required String templateType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      final modifiedFile = await _generationService.generateExif(
        imageFile: imageFile,
        templateType: templateType,
      );
      
      final log = _manipulationService.createLog(
        evidenceId: 'EV-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.exifGenerated,
        changes: {
          'template': templateType,
        },
      );
      
      await _firestoreLoggingDatasource.logManipulation(log);
      
      return Right(modifiedFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, ImageEvidence>> createEvidence({
    required File imageFile,
    String? caseId,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('User not authenticated'));
      }
      
      // Save original image
      final evidenceId = 'EV-${DateTime.now().millisecondsSinceEpoch}';
      final originalFile = await _localImageDatasource.saveImage(
        imageFile,
        'original_$evidenceId.jpg',
      );
      
      // Extract EXIF
      final exifData = await _exifParsingDatasource.extractExif(imageFile);
      
      // Create evidence
      final evidence = ImageEvidence(
        evidenceId: evidenceId,
        originalPath: originalFile.path,
        originalExif: exifData,
        caseId: caseId,
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        createdAt: DateTime.now(),
        description: description,
        tags: tags ?? [],
      );
      
      // Log creation
      final log = ManipulationLog(
        logId: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
        evidenceId: evidenceId,
        userId: user.uid,
        userEmail: user.email ?? 'unknown',
        action: ManipulationAction.exifExtracted,
        changes: {'created': true},
        timestamp: DateTime.now().toUtc(),
        reason: 'Evidence created',
        caseId: caseId,
      );
      
      await _firestoreLoggingDatasource.logManipulation(log);
      
      return Right(evidence);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, File>> exportEvidencePdf(ImageEvidence evidence) async {
    try {
      final pdfFile = await _exportService.generatePdfReport(evidence);
      
      // Log export
      final user = _auth.currentUser;
      if (user != null) {
        await _firestoreLoggingDatasource.logActivity(
          userId: user.uid,
          userEmail: user.email ?? 'unknown',
          action: 'EVIDENCE_EXPORTED',
          details: {
            'evidenceId': evidence.evidenceId,
            'format': 'PDF',
          },
        );
      }
      
      return Right(pdfFile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logManipulation(ManipulationLog log) async {
    try {
      await _firestoreLoggingDatasource.logManipulation(log);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ManipulationLog>>> getManipulationHistory(
    String evidenceId,
  ) async {
    try {
      final history = await _firestoreLoggingDatasource.getManipulationHistory(
        evidenceId,
      );
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
