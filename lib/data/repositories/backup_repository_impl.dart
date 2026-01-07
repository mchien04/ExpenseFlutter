import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/repositories/backup_repository.dart';
import '../services/backup_service.dart';

class BackupRepositoryImpl implements BackupRepository {
  final BackupService _backupService;

  BackupRepositoryImpl(this._backupService);

  @override
  Future<Either<Failure, String>> exportToJson() async {
    try {
      final jsonData = await _backupService.exportToJson();
      return Right(jsonData);
    } catch (e) {
      return Left(BackupFailure('Lỗi xuất dữ liệu JSON: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportToCsv() async {
    try {
      final csvData = await _backupService.exportToCsv();
      return Right(csvData);
    } catch (e) {
      return Left(BackupFailure('Lỗi xuất dữ liệu CSV: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> importFromJson(String jsonData) async {
    try {
      await _backupService.importFromJson(jsonData);
      return const Right(null);
    } catch (e) {
      return Left(RestoreFailure('Lỗi khôi phục dữ liệu: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      await _backupService.clearAllData();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa dữ liệu: $e'));
    }
  }
}
