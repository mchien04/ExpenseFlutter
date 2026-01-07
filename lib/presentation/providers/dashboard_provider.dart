import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/enums.dart';
import '../../core/utils/date_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../widgets/charts/expense_pie_chart.dart';
import '../widgets/charts/income_expense_bar_chart.dart';
import '../theme/app_colors.dart';
import 'category_provider.dart';
import 'transaction_provider.dart';
import 'wallet_provider.dart';

final statsSelectedWalletIdProvider = StateProvider<String?>((ref) => null);

final statsMonthlyTransactionsProvider =
    Provider.autoDispose<List<TransactionEntity>>((ref) {
  final selectedWalletId = ref.watch(statsSelectedWalletIdProvider);
  final transactionsAsync = ref.watch(monthlyTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final completed = transactions
          .where((t) => t.status == TransactionStatus.completed)
          .toList();

      if (selectedWalletId == null) return completed;
      return completed.where((t) => t.walletId == selectedWalletId).toList();
    },
    loading: () => <TransactionEntity>[],
    error: (_, __) => <TransactionEntity>[],
  );
});

final totalBalanceProvider = FutureProvider.autoDispose<double>((ref) async {
  final walletsWithBalance = await ref.watch(walletsWithBalanceProvider.future);
  return walletsWithBalance.fold<double>(0, (sum, w) => sum + w.balance);
});

final expenseByCategoryProvider =
    Provider.autoDispose<List<ExpenseByCategoryData>>((ref) {
  final filteredTransactions = ref.watch(statsMonthlyTransactionsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  return categoriesAsync.when(
    data: (categories) {
      return _calculateExpenseByCategory(filteredTransactions, categories);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

List<ExpenseByCategoryData> _calculateExpenseByCategory(
  List<TransactionEntity> transactions,
  List<CategoryEntity> categories,
) {
  final expenseTransactions =
      transactions.where((t) => t.type == TransactionType.expense).toList();

  if (expenseTransactions.isEmpty) return [];

  final Map<String, double> categoryAmounts = {};
  double totalExpense = 0;

  for (final t in expenseTransactions) {
    categoryAmounts[t.categoryId] =
        (categoryAmounts[t.categoryId] ?? 0) + t.amount;
    totalExpense += t.amount;
  }
  final categoryMap = {for (var c in categories) c.id: c};

  final result = categoryAmounts.entries.map((entry) {
    final category = categoryMap[entry.key];
    final color = category != null
        ? Color(int.parse('FF${category.colorHex}', radix: 16))
        : AppColors.chartColors[categoryAmounts.keys.toList().indexOf(entry.key) %
            AppColors.chartColors.length];

    return ExpenseByCategoryData(
      categoryId: entry.key,
      categoryName: category?.name ?? 'Không xác định',
      color: color,
      amount: entry.value,
      percentage: totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0,
    );
  }).toList();

  result.sort((a, b) => b.amount.compareTo(a.amount));
  return result;
}

class StatsSummaryData {
  final double income;
  final double expense;

  StatsSummaryData({required this.income, required this.expense});
}

final statsMonthlySummaryProvider = Provider.autoDispose<StatsSummaryData>((ref) {
  final transactions = ref.watch(statsMonthlyTransactionsProvider);

  double income = 0;
  double expense = 0;

  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }

  return StatsSummaryData(income: income, expense: expense);
});

final statsLast7DaysDataProvider =
    Provider.autoDispose<List<DailyIncomeExpenseData>>((ref) {
  final selectedWalletId = ref.watch(statsSelectedWalletIdProvider);
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final completed = transactions
          .where((t) => t.status == TransactionStatus.completed)
          .toList();

      final filtered = selectedWalletId == null
          ? completed
          : completed.where((t) => t.walletId == selectedWalletId).toList();

      return _calculateLast7DaysData(filtered);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class WalletSpendingData {
  final String walletId;
  final String walletName;
  final String currencyCode;
  final double income;
  final double expense;

  WalletSpendingData({
    required this.walletId,
    required this.walletName,
    required this.currencyCode,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

final spendingByWalletProvider =
    Provider.autoDispose<List<WalletSpendingData>>((ref) {
  final walletsAsync = ref.watch(walletsProvider);
  final transactionsAsync = ref.watch(monthlyTransactionsProvider);

  return walletsAsync.when(
    data: (wallets) {
      final walletMap = {for (final w in wallets) w.id: w};

      return transactionsAsync.when(
        data: (transactions) {
          final completed = transactions
              .where((t) => t.status == TransactionStatus.completed)
              .toList();

          final Map<String, double> incomeMap = {};
          final Map<String, double> expenseMap = {};

          for (final t in completed) {
            if (t.type == TransactionType.income) {
              incomeMap[t.walletId] = (incomeMap[t.walletId] ?? 0) + t.amount;
            } else {
              expenseMap[t.walletId] = (expenseMap[t.walletId] ?? 0) + t.amount;
            }
          }

          final walletIds = {
            ...incomeMap.keys,
            ...expenseMap.keys,
            ...walletMap.keys,
          };

          final result = walletIds.map((walletId) {
            final wallet = walletMap[walletId];
            return WalletSpendingData(
              walletId: walletId,
              walletName: wallet?.name ?? 'Không xác định',
              currencyCode: wallet?.currencyCode ?? 'VND',
              income: incomeMap[walletId] ?? 0,
              expense: expenseMap[walletId] ?? 0,
            );
          }).toList();

          result.sort((a, b) => b.expense.compareTo(a.expense));
          return result;
        },
        loading: () => <WalletSpendingData>[],
        error: (_, __) => <WalletSpendingData>[],
      );
    },
    loading: () => <WalletSpendingData>[],
    error: (_, __) => <WalletSpendingData>[],
  );
});

final last7DaysDataProvider =
    Provider.autoDispose<List<DailyIncomeExpenseData>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.when(
    data: (transactions) => _calculateLast7DaysData(transactions),
    loading: () => [],
    error: (_, __) => [],
  );
});

List<DailyIncomeExpenseData> _calculateLast7DaysData(
  List<TransactionEntity> transactions,
) {
  final now = DateTime.now();
  final result = <DailyIncomeExpenseData>[];

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day - i);
    final dayStart = AppDateUtils.startOfDay(date);
    final dayEnd = AppDateUtils.endOfDay(date);

    final dayTransactions = transactions.where((t) =>
        t.date.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
        t.date.isBefore(dayEnd.add(const Duration(seconds: 1))) &&
        t.status == TransactionStatus.completed);

    double income = 0;
    double expense = 0;

    for (final t in dayTransactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    result.add(DailyIncomeExpenseData(
      date: date,
      income: income,
      expense: expense,
    ));
  }

  return result;
}

final recentTransactionsProvider =
    Provider.autoDispose<List<TransactionEntity>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final sorted = [...transactions];
      sorted.sort((a, b) => b.date.compareTo(a.date));
      return sorted.take(5).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
