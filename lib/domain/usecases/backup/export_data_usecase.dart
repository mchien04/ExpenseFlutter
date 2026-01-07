import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/backup_repository.dart';

class ExportDataUseCase {
  final BackupRepository repository;

  ExportDataUseCase(this.repository);

  Future<Either<Failure, String>> toJson() {
    return repository.exportToJson();
  }

  Future<Either<Failure, String>> toCsv() {
    return repository.exportToCsv();
  }
}
