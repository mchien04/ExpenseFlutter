import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.softDeleteCategory(id);
  }

  Future<Either<Failure, void>> restore(String id) {
    return repository.restoreCategory(id);
  }
}
