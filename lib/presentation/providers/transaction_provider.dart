import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/transaction/get_transaction_summary_usecase.dart';
import '../../injection_container.dart';
import 'wallet_provider.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final transactionsProvider =
    StreamProvider.autoDispose<List<TransactionEntity>>((ref) {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase.watch().map((result) => result.fold(
        (failure) => <TransactionEntity>[],
        (transactions) => transactions,
      ));
});

final monthlyTransactionsProvider =
    StreamProvider.autoDispose<List<TransactionEntity>>((ref) {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final startOfMonth = AppDateUtils.startOfMonth(selectedMonth);
  final endOfMonth = AppDateUtils.endOfMonth(selectedMonth);

  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase.watchByDateRange(startOfMonth, endOfMonth).map((result) =>
      result.fold(
        (failure) => <TransactionEntity>[],
        (transactions) => transactions,
      ));
});

final walletTransactionsProvider = StreamProvider.autoDispose
    .family<List<TransactionEntity>, String>((ref, walletId) {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  return useCase.watchByWallet(walletId).map((result) => result.fold(
        (failure) => <TransactionEntity>[],
        (transactions) => transactions,
      ));
});

final monthlySummaryProvider =
    FutureProvider.autoDispose<TransactionSummary?>((ref) async {
  final selectedMonth = ref.watch(selectedMonthProvider);
  final startOfMonth = AppDateUtils.startOfMonth(selectedMonth);
  final endOfMonth = AppDateUtils.endOfMonth(selectedMonth);

  final useCase = ref.watch(getTransactionSummaryUseCaseProvider);
  final result = await useCase.call(startDate: startOfMonth, endDate: endOfMonth);
  return result.fold(
    (failure) => null,
    (summary) => summary,
  );
});

final pendingTransactionsProvider =
    FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
  final useCase = ref.watch(getTransactionsUseCaseProvider);
  final result = await useCase.pending();
  return result.fold(
    (failure) => <TransactionEntity>[],
    (transactions) => transactions,
  );
});

class TransactionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  TransactionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createTransaction({
    required double amount,
    required TransactionType type,
    required String categoryId,
    required String walletId,
    required DateTime date,
    String note = '',
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(createTransactionUseCaseProvider).call(
          amount: amount,
          type: type,
          categoryId: categoryId,
          walletId: walletId,
          date: date,
          note: note,
        );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(monthlySummaryProvider);
        _ref.invalidate(walletsWithBalanceProvider);
        return true;
      },
    );
  }

  Future<bool> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(updateTransactionUseCaseProvider).call(transaction);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(monthlySummaryProvider);
        _ref.invalidate(walletsWithBalanceProvider);
        return true;
      },
    );
  }

  Future<bool> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(deleteTransactionUseCaseProvider).call(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(monthlySummaryProvider);
        _ref.invalidate(walletsWithBalanceProvider);
        return true;
      },
    );
  }
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<void>>((ref) {
  return TransactionNotifier(ref);
});
