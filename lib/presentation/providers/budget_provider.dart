import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/budget/check_budget_status_usecase.dart';
import '../../injection_container.dart';

final budgetsProvider = StreamProvider.autoDispose<List<BudgetEntity>>((ref) {
  final useCase = ref.watch(getBudgetsUseCaseProvider);
  return useCase.watch().map((result) => result.fold(
        (failure) => <BudgetEntity>[],
        (budgets) => budgets,
      ));
});

final budgetStatusProvider =
    FutureProvider.autoDispose.family<BudgetStatus?, String>((ref, categoryId) async {
  final useCase = ref.watch(checkBudgetStatusUseCaseProvider);
  final result = await useCase.call(categoryId);
  return result.fold(
    (failure) => null,
    (status) => status,
  );
});

final allBudgetStatusesProvider =
    FutureProvider.autoDispose<List<BudgetStatus>>((ref) async {
  final useCase = ref.watch(checkBudgetStatusUseCaseProvider);
  final result = await useCase.checkAllBudgets();
  return result.fold(
    (failure) => <BudgetStatus>[],
    (statuses) => statuses,
  );
});

final overBudgetAlertsProvider =
    FutureProvider.autoDispose<List<BudgetStatus>>((ref) async {
  final statusesAsync = ref.watch(allBudgetStatusesProvider);
  return statusesAsync.when(
    data: (statuses) =>
        statuses.where((s) => s.isOverBudget || s.isNearLimit).toList(),
    loading: () => <BudgetStatus>[],
    error: (_, __) => <BudgetStatus>[],
  );
});

class BudgetNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  BudgetNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createBudget({
    required String categoryId,
    required double limitAmount,
    BudgetPeriod period = BudgetPeriod.monthly,
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(createBudgetUseCaseProvider).call(
          categoryId: categoryId,
          limitAmount: limitAmount,
          period: period,
        );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(allBudgetStatusesProvider);
        return true;
      },
    );
  }

  Future<bool> updateBudget(BudgetEntity budget) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(updateBudgetUseCaseProvider).call(budget);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(allBudgetStatusesProvider);
        return true;
      },
    );
  }

  Future<bool> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(deleteBudgetUseCaseProvider).call(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(allBudgetStatusesProvider);
        return true;
      },
    );
  }
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, AsyncValue<void>>((ref) {
  return BudgetNotifier(ref);
});
