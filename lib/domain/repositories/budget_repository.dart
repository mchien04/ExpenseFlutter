import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets();
  Future<Either<Failure, BudgetEntity?>> getBudgetById(String id);
  Future<Either<Failure, BudgetEntity?>> getBudgetByCategory(String categoryId);
  Stream<Either<Failure, List<BudgetEntity>>> watchAllBudgets();
  Stream<Either<Failure, BudgetEntity?>> watchBudgetByCategory(
      String categoryId);
  Future<Either<Failure, void>> insertBudget(BudgetEntity budget);
  Future<Either<Failure, void>> updateBudget(BudgetEntity budget);
  Future<Either<Failure, void>> deleteBudget(String id);
  Future<Either<Failure, bool>> budgetExistsForCategory(String categoryId);
}
