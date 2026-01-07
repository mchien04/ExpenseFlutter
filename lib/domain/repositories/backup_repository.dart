import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';

abstract class BackupRepository {
  Future<Either<Failure, String>> exportToJson();
  Future<Either<Failure, String>> exportToCsv();
  Future<Either<Failure, void>> importFromJson(String jsonData);
  Future<Either<Failure, void>> clearAllData();
}
