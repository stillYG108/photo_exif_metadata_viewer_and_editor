import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/forensic_case.dart';

/// Forensic Case Repository Interface (Domain Layer)
abstract class ForensicCaseRepository {
  /// Get all cases for the current user
  Future<Either<Failure, List<ForensicCase>>> getCases();
  
  /// Get cases filtered by status
  Future<Either<Failure, List<ForensicCase>>> getCasesByStatus(CaseStatus status);
  
  /// Get a specific case by ID
  Future<Either<Failure, ForensicCase>> getCaseById(String caseId);
  
  /// Create a new case
  Future<Either<Failure, String>> createCase(ForensicCase forensicCase);
  
  /// Update an existing case
  Future<Either<Failure, void>> updateCase(ForensicCase forensicCase);
  
  /// Delete a case
  Future<Either<Failure, void>> deleteCase(String caseId);
  
  /// Get cases assigned to a specific user
  Future<Either<Failure, List<ForensicCase>>> getCasesAssignedTo(String userId);
  
  /// Get cases created by a specific user
  Future<Either<Failure, List<ForensicCase>>> getCasesCreatedBy(String userId);
}
