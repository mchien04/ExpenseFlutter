import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/wallet_entity.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/date_formatter.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/charts/charts.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedWalletId = ref.watch(statsSelectedWalletIdProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final statsSummary = ref.watch(statsMonthlySummaryProvider);
    final expenseByCategory = ref.watch(expenseByCategoryProvider);
    final last7DaysData = ref.watch(statsLast7DaysDataProvider);
    final spendingByWallet = ref.watch(spendingByWalletProvider);

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showMonthPicker(context, ref),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormatter.formatMonthYear(selectedMonth)),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWalletFilter(
            context: context,
            ref: ref,
            isDark: isDark,
            selectedWalletId: selectedWalletId,
            walletsAsync: walletsAsync,
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(statsSummary, isDark),
          const SizedBox(height: 24),
          ExpensePieChart(
            data: expenseByCategory,
            totalExpense: statsSummary.expense,
          ),
          const SizedBox(height: 16),
          IncomeExpenseBarChart(data: last7DaysData),
          const SizedBox(height: 16),
          _buildWalletBreakdown(
            data: spendingByWallet,
            isDark: isDark,
            selectedWalletId: selectedWalletId,
            onSelectWallet: (id) =>
                ref.read(statsSelectedWalletIdProvider.notifier).state = id,
          ),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(expenseByCategory, isDark),
        ],
      ),
    );
  }

  Widget _buildWalletFilter({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String? selectedWalletId,
    required AsyncValue<List<WalletEntity>> walletsAsync,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc theo ví',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),
          walletsAsync.when(
            data: (wallets) {
              // Check if selected wallet still exists, if not reset to null
              final walletIds = wallets.map((w) => w.id).toSet();
              final validSelectedId = selectedWalletId != null && walletIds.contains(selectedWalletId)
                  ? selectedWalletId
                  : null;
              
              // Reset if invalid
              if (validSelectedId != selectedWalletId) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(statsSelectedWalletIdProvider.notifier).state = null;
                });
              }
              
              return DropdownButtonFormField<String?>(
                value: validSelectedId,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Tất cả ví'),
                  ),
                  ...wallets.map((w) => DropdownMenuItem<String?>(
                        value: w.id,
                        child: Text(w.name),
                      )),
                ],
                onChanged: (value) {
                  ref.read(statsSelectedWalletIdProvider.notifier).state = value;
                },
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Lỗi: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBreakdown({
    required List<WalletSpendingData> data,
    required bool isDark,
    required String? selectedWalletId,
    required ValueChanged<String?> onSelectWallet,
  }) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theo ví',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () => onSelectWallet(null),
                child: const Text('Tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.map((w) {
            final isSelected = selectedWalletId == w.walletId;
            final borderColor = isSelected
                ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

            final bgColor = isSelected
                ? (isDark
                    ? AppColors.primaryDark.withAlpha(20)
                    : AppColors.primaryLight.withAlpha(20))
                : Colors.transparent;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelectWallet(w.walletId),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          w.walletName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Chi: ${CurrencyFormatter.formatCompact(w.expense)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thu: ${CurrencyFormatter.formatCompact(w.income)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.income,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(StatsSummaryData summary, bool isDark) {
    final totalIncome = summary.income;
    final totalExpense = summary.expense;
    final balance = totalIncome - totalExpense;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Thu nhập',
                amount: totalIncome,
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Chi tiêu',
                amount: totalExpense,
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          title: 'Chênh lệch tháng này',
          amount: balance,
          color: balance >= 0 ? AppColors.income : AppColors.expense,
          icon: balance >= 0 ? Icons.trending_up : Icons.trending_down,
          isDark: isDark,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required bool isDark,
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: isLarge ? 24 : 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(amount),
                  style: TextStyle(
                    fontSize: isLarge ? 20 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    List<ExpenseByCategoryData> data,
    bool isDark,
  ) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết theo danh mục',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((item) => _buildCategoryRow(item, isDark)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(ExpenseByCategoryData item, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: item.percentage / 100,
                    backgroundColor: item.color.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatCompact(item.amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) async {
    final selectedMonth = ref.read(selectedMonthProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      ref.read(selectedMonthProvider.notifier).state = picked;
    }
  }
}
