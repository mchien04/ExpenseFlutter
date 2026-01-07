import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/enums/enums.dart';
import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<CategoryEntity>>> call() {
    return repository.getActiveCategories();
  }

  Future<Either<Failure, List<CategoryEntity>>> byType(TransactionType type) {
    return repository.getCategoriesByType(type);
  }

  Stream<Either<Failure, List<CategoryEntity>>> watch() {
    return repository.watchActiveCategories();
  }

  Stream<Either<Failure, List<CategoryEntity>>> watchByType(
      TransactionType type) {
    return repository.watchCategoriesByType(type);
  }
}
