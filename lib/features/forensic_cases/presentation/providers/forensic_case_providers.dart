import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/forensic_case_remote_datasource.dart';
import '../../data/repositories/forensic_case_repository_impl.dart';
import '../../domain/repositories/forensic_case_repository.dart';

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Remote datasource provider
final forensicCaseRemoteDatasourceProvider = Provider<ForensicCaseRemoteDatasource>((ref) {
  return ForensicCaseRemoteDatasource(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

/// Repository provider
final forensicCaseRepositoryProvider = Provider<ForensicCaseRepository>((ref) {
  return ForensicCaseRepositoryImpl(
    remoteDatasource: ref.watch(forensicCaseRemoteDatasourceProvider),
  );
});
