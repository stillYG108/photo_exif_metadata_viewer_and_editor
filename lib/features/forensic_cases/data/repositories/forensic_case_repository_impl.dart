import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/forensic_case.dart';
import '../../domain/repositories/forensic_case_repository.dart';
import '../datasources/forensic_case_remote_datasource.dart';
import '../models/forensic_case_model.dart';

/// Forensic Case Repository Implementation
class ForensicCaseRepositoryImpl implements ForensicCaseRepository {
  final ForensicCaseRemoteDatasource remoteDatasource;
  
  ForensicCaseRepositoryImpl({required this.remoteDatasource});
  
  @override
  Future<Either<Failure, List<ForensicCase>>> getCases() async {
    try {
      final cases = await remoteDatasource.getCases();
      return Right(cases);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<ForensicCase>>> getCasesByStatus(
    CaseStatus status,
  ) async {
    try {
      final cases = await remoteDatasource.getCasesByStatus(status.name);
      return Right(cases);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, ForensicCase>> getCaseById(String caseId) async {
    try {
      final forensicCase = await remoteDatasource.getCaseById(caseId);
      return Right(forensicCase);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, String>> createCase(ForensicCase forensicCase) async {
    try {
      final model = ForensicCaseModel.fromEntity(forensicCase);
      final caseId = await remoteDatasource.createCase(model);
      return Right(caseId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> updateCase(ForensicCase forensicCase) async {
    try {
      final model = ForensicCaseModel.fromEntity(forensicCase);
      await remoteDatasource.updateCase(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> deleteCase(String caseId) async {
    try {
      await remoteDatasource.deleteCase(caseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<ForensicCase>>> getCasesAssignedTo(
    String userId,
  ) async {
    try {
      final cases = await remoteDatasource.getCasesAssignedTo(userId);
      return Right(cases);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<ForensicCase>>> getCasesCreatedBy(
    String userId,
  ) async {
    try {
      final cases = await remoteDatasource.getCasesCreatedBy(userId);
      return Right(cases);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }
}
