import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/exif_parsing_datasource.dart';
import '../../data/datasources/local_image_datasource.dart';
import '../../data/datasources/firestore_logging_datasource.dart';
import '../../data/services/exif_extraction_service.dart';
import '../../data/services/exif_manipulation_service.dart';
import '../../data/services/exif_generation_service.dart';
import '../../data/services/evidence_export_service.dart';
import '../../data/repositories/exif_repository_impl.dart';
import '../../domain/repositories/exif_repository.dart';

/// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Datasource providers
final exifParsingDatasourceProvider = Provider<ExifParsingDatasource>((ref) {
  return ExifParsingDatasource();
});

final localImageDatasourceProvider = Provider<LocalImageDatasource>((ref) {
  return LocalImageDatasource();
});

final firestoreLoggingDatasourceProvider = Provider<FirestoreLoggingDatasource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreLoggingDatasource(firestore);
});

/// Service providers
final exifExtractionServiceProvider = Provider<ExifExtractionService>((ref) {
  final localDatasource = ref.watch(localImageDatasourceProvider);
  return ExifExtractionService(localDatasource);
});

final exifManipulationServiceProvider = Provider<ExifManipulationService>((ref) {
  final localDatasource = ref.watch(localImageDatasourceProvider);
  return ExifManipulationService(localDatasource);
});

final exifGenerationServiceProvider = Provider<ExifGenerationService>((ref) {
  final localDatasource = ref.watch(localImageDatasourceProvider);
  return ExifGenerationService(localDatasource);
});

final evidenceExportServiceProvider = Provider<EvidenceExportService>((ref) {
  final localDatasource = ref.watch(localImageDatasourceProvider);
  return EvidenceExportService(localDatasource);
});

/// Repository provider
final exifRepositoryProvider = Provider<ExifRepository>((ref) {
  return ExifRepositoryImpl(
    exifParsingDatasource: ref.watch(exifParsingDatasourceProvider),
    localImageDatasource: ref.watch(localImageDatasourceProvider),
    firestoreLoggingDatasource: ref.watch(firestoreLoggingDatasourceProvider),
    extractionService: ref.watch(exifExtractionServiceProvider),
    manipulationService: ref.watch(exifManipulationServiceProvider),
    generationService: ref.watch(exifGenerationServiceProvider),
    exportService: ref.watch(evidenceExportServiceProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});
