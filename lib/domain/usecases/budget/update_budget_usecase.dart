import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';
import '../../validators/budget_validator.dart';

class UpdateBudgetUseCase {
  final BudgetRepository repository;

  UpdateBudgetUseCase(this.repository);

  Future<Either<Failure, void>> call(BudgetEntity budget) async {
    final updatedBudget = budget.copyWith(updatedAt: DateTime.now());

    final validationResult = BudgetValidator.validate(updatedBudget);
    return validationResult.fold(
      (failure) => Left(failure),
      (validBudget) => repository.updateBudget(validBudget),
    );
  }
}
