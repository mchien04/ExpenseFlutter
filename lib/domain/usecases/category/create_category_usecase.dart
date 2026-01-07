import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../core/enums/enums.dart';
import '../../entities/category_entity.dart';
import '../../repositories/category_repository.dart';
import '../../validators/category_validator.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;
  final Uuid _uuid = const Uuid();

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required TransactionType type,
    required int iconCodePoint,
    required String colorHex,
  }) async {
    final now = DateTime.now();
    final category = CategoryEntity(
      id: _uuid.v4(),
      name: name,
      type: type,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );

    final validationResult = CategoryValidator.validate(category);
    return validationResult.fold(
      (failure) => Left(failure),
      (validCategory) => repository.insertCategory(validCategory),
    );
  }
}
