import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/backup_repository.dart';

class ImportDataUseCase {
  final BackupRepository repository;

  ImportDataUseCase(this.repository);

  Future<Either<Failure, void>> fromJson(String jsonData) {
    return repository.importFromJson(jsonData);
  }

  Future<Either<Failure, void>> clearAllData() {
    return repository.clearAllData();
  }
}
