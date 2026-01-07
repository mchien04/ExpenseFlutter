import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/utils/date_utils.dart';
import '../../entities/budget_entity.dart';
import '../../repositories/budget_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../validators/budget_validator.dart';

class BudgetStatus {
  final BudgetEntity budget;
  final double spent;
  final double remaining;
  final double percentage;
  final bool isOverBudget;
  final bool isNearLimit;

  BudgetStatus({
    required this.budget,
    required this.spent,
  })  : remaining = budget.limitAmount - spent,
        percentage =
            BudgetValidator.calculateUsagePercentage(spent, budget.limitAmount),
        isOverBudget = BudgetValidator.isOverBudget(spent, budget.limitAmount),
        isNearLimit = BudgetValidator.isNearLimit(spent, budget.limitAmount);
}

class CheckBudgetStatusUseCase {
  final BudgetRepository budgetRepository;
  final TransactionRepository transactionRepository;

  CheckBudgetStatusUseCase({
    required this.budgetRepository,
    required this.transactionRepository,
  });

  Future<Either<Failure, BudgetStatus?>> call(String categoryId) async {
    final budgetResult = await budgetRepository.getBudgetByCategory(categoryId);

    return budgetResult.fold(
      (failure) => Left(failure),
      (budget) async {
        if (budget == null) {
          return const Right(null);
        }

        final now = DateTime.now();
        final startOfMonth = AppDateUtils.startOfMonth(now);
        final endOfMonth = AppDateUtils.endOfMonth(now);

        final spentResult = await transactionRepository.getTotalByTypeAndDateRange(
          'expense',
          startOfMonth,
          endOfMonth,
        );

        return spentResult.fold(
          (failure) => Left(failure),
          (totalSpent) {
            // Get spent for this specific category
            return _getSpentForCategory(
                categoryId, startOfMonth, endOfMonth, budget);
          },
        );
      },
    );
  }

  Future<Either<Failure, BudgetStatus>> _getSpentForCategory(
    String categoryId,
    DateTime start,
    DateTime end,
    BudgetEntity budget,
  ) async {
    final transactionsResult = await transactionRepository
        .getTransactionsByCategoryAndDateRange(categoryId, start, end);

    return transactionsResult.fold(
      (failure) => Left(failure),
      (transactions) {
        final spent = transactions
            .where((t) => t.type.name == 'expense')
            .fold<double>(0, (sum, t) => sum + t.amount);

        return Right(BudgetStatus(budget: budget, spent: spent));
      },
    );
  }

  Future<Either<Failure, List<BudgetStatus>>> checkAllBudgets() async {
    final budgetsResult = await budgetRepository.getAllBudgets();

    return budgetsResult.fold(
      (failure) => Left(failure),
      (budgets) async {
        final statuses = <BudgetStatus>[];

        for (final budget in budgets) {
          final statusResult = await call(budget.categoryId);
          statusResult.fold(
            (_) {},
            (status) {
              if (status != null) {
                statuses.add(status);
              }
            },
          );
        }

        return Right(statuses);
      },
    );
  }
}
