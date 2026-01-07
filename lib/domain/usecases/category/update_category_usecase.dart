import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';
import '../../validators/category_validator.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(CategoryEntity category) async {
    final updatedCategory = category.copyWith(updatedAt: DateTime.now());

    final validationResult = CategoryValidator.validate(updatedCategory);
    return validationResult.fold(
      (failure) => Left(failure),
      (validCategory) => repository.updateCategory(validCategory),
    );
  }
}
