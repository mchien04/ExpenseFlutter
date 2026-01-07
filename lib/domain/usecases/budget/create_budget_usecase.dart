import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/failures.dart';
import '../../../core/enums/enums.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/category_repository.dart';
import '../../validators/budget_validator.dart';

class CreateBudgetUseCase {
  final BudgetRepository budgetRepository;
  final CategoryRepository categoryRepository;
  final Uuid _uuid = const Uuid();

  CreateBudgetUseCase({
    required this.budgetRepository,
    required this.categoryRepository,
  });

  Future<Either<Failure, void>> call({
    required String categoryId,
    required double limitAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) async {
    // Verify category exists
    final categoryExists = await categoryRepository.categoryExists(categoryId);
    if (categoryExists.isLeft()) {
      return categoryExists.fold(
        (failure) => Left(failure),
        (_) => const Left(ValidationFailure('Lỗi kiểm tra danh mục')),
      );
    }
    final categoryValid = categoryExists.getOrElse(() => false);
    if (!categoryValid) {
      return const Left(ValidationFailure('Danh mục không tồn tại'));
    }

    // Check if budget already exists for category
    final existingBudget =
        await budgetRepository.budgetExistsForCategory(categoryId);
    if (existingBudget.isRight() && existingBudget.getOrElse(() => false)) {
      return const Left(
          ValidationFailure('Ngân sách cho danh mục này đã tồn tại'));
    }

    final now = DateTime.now();
    final budget = BudgetEntity(
      id: _uuid.v4(),
      categoryId: categoryId,
      limitAmount: limitAmount,
      period: period,
      createdAt: now,
      updatedAt: now,
    );

    final validationResult = BudgetValidator.validate(budget);
    return validationResult.fold(
      (failure) => Left(failure),
      (validBudget) => budgetRepository.insertBudget(validBudget),
    );
  }
}
