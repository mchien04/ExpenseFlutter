import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/recurring_template_entity.dart';
import '../../domain/repositories/recurring_template_repository.dart';
import '../datasources/local/database/app_database.dart';
import '../mappers/recurring_template_mapper.dart';

class RecurringTemplateRepositoryImpl implements RecurringTemplateRepository {
  final AppDatabase _database;

  RecurringTemplateRepositoryImpl(this._database);

  @override
  Future<Either<Failure, List<RecurringTemplateEntity>>>
      getAllTemplates() async {
    try {
      final rows = await _database.recurringTemplateDao.getAllTemplates();
      return Right(RecurringTemplateMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy danh sách mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringTemplateEntity>>>
      getActiveTemplates() async {
    try {
      final rows = await _database.recurringTemplateDao.getActiveTemplates();
      return Right(RecurringTemplateMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy mẫu định kỳ hoạt động: $e'));
    }
  }

  @override
  Future<Either<Failure, RecurringTemplateEntity?>> getTemplateById(
      String id) async {
    try {
      final row = await _database.recurringTemplateDao.getTemplateById(id);
      if (row == null) return const Right(null);
      return Right(RecurringTemplateMapper.fromDriftRow(row));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RecurringTemplateEntity>>>
      getTemplatesDueForExecution(DateTime date) async {
    try {
      final rows =
          await _database.recurringTemplateDao.getTemplatesDueForExecution(date);
      return Right(RecurringTemplateMapper.fromDriftRowList(rows));
    } catch (e) {
      return Left(DatabaseFailure('Lỗi lấy mẫu định kỳ cần thực thi: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<RecurringTemplateEntity>>> watchAllTemplates() {
    return _database.recurringTemplateDao.watchAllTemplates().map((rows) {
      try {
        return Right(RecurringTemplateMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi mẫu định kỳ: $e'));
      }
    });
  }

  @override
  Stream<Either<Failure, List<RecurringTemplateEntity>>>
      watchActiveTemplates() {
    return _database.recurringTemplateDao.watchActiveTemplates().map((rows) {
      try {
        return Right(RecurringTemplateMapper.fromDriftRowList(rows));
      } catch (e) {
        return Left(DatabaseFailure('Lỗi theo dõi mẫu định kỳ: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> insertTemplate(
      RecurringTemplateEntity template) async {
    try {
      final companion = RecurringTemplateMapper.toCompanion(template);
      await _database.recurringTemplateDao.insertTemplate(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi thêm mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateTemplate(
      RecurringTemplateEntity template) async {
    try {
      final companion = RecurringTemplateMapper.toCompanion(template);
      await _database.recurringTemplateDao.updateTemplate(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNextExecutionDate(
      String id, DateTime nextDate) async {
    try {
      await _database.recurringTemplateDao
          .updateNextExecutionDate(id, nextDate);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi cập nhật ngày thực thi: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateTemplate(String id) async {
    try {
      await _database.recurringTemplateDao.deactivateTemplate(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi vô hiệu hóa mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> activateTemplate(String id) async {
    try {
      await _database.recurringTemplateDao.activateTemplate(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi kích hoạt mẫu định kỳ: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTemplate(String id) async {
    try {
      await _database.recurringTemplateDao.deleteTemplate(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Lỗi xóa mẫu định kỳ: $e'));
    }
  }
}
