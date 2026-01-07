import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';

class GetBudgetsUseCase {
  final BudgetRepository repository;

  GetBudgetsUseCase(this.repository);

  Future<Either<Failure, List<BudgetEntity>>> call() {
    return repository.getAllBudgets();
  }

  Future<Either<Failure, BudgetEntity?>> byId(String id) {
    return repository.getBudgetById(id);
  }

  Future<Either<Failure, BudgetEntity?>> byCategory(String categoryId) {
    return repository.getBudgetByCategory(categoryId);
  }

  Stream<Either<Failure, List<BudgetEntity>>> watch() {
    return repository.watchAllBudgets();
  }

  Stream<Either<Failure, BudgetEntity?>> watchByCategory(String categoryId) {
    return repository.watchBudgetByCategory(categoryId);
  }
}
