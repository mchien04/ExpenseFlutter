import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../helpers/date_formatter.dart';
import '../../providers/category_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/widgets.dart';
import '../wallet/wallets_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(walletsWithBalanceProvider);
            ref.invalidate(monthlySummaryProvider);
            ref.invalidate(transactionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(context, ref),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummarySection(ref),
                    const SizedBox(height: 24),
                    _buildWalletsSection(context, ref),
                    const SizedBox(height: 24),
                    _buildChartsSection(context, ref),
                    const SizedBox(height: 24),
                    _buildRecentTransactionsSection(context, ref),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      floating: true,
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      title: GestureDetector(
        onTap: () => _showMonthPicker(context, ref),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormatter.formatMonthYear(selectedMonth),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSummarySection(WidgetRef ref) {
    final totalBalanceAsync = ref.watch(totalBalanceProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return totalBalanceAsync.when(
      data: (totalBalance) {
        return summaryAsync.when(
          data: (summary) {
            return SummaryCard(
              totalBalance: totalBalance,
              income: summary?.totalIncome ?? 0,
              expense: summary?.totalExpense ?? 0,
              periodLabel: 'Tháng này',
            );
          },
          loading: () => const SummaryCard(
            totalBalance: 0,
            income: 0,
            expense: 0,
          ),
          error: (_, __) => const SummaryCard(
            totalBalance: 0,
            income: 0,
            expense: 0,
          ),
        );
      },
      loading: () => const SummaryCard(
        totalBalance: 0,
        income: 0,
        expense: 0,
      ),
      error: (_, __) => const SummaryCard(
        totalBalance: 0,
        income: 0,
        expense: 0,
      ),
    );
  }

  Widget _buildWalletsSection(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsWithBalanceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ví của tôi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WalletsScreen(),
                    ),
                  );
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        walletsAsync.when(
          data: (wallets) {
            if (wallets.isEmpty) {
              return SizedBox(
                height: 140,
                child: Center(
                  child: Text(
                    'Chưa có ví nào',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              );
            }
            return WalletCardList(
              wallets: wallets
                  .map((w) => WalletCardData(
                        id: w.wallet.id,
                        name: w.wallet.name,
                        balance: w.balance,
                        currencyCode: w.wallet.currencyCode,
                      ))
                  .toList(),
              onWalletTap: (walletId) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WalletsScreen(),
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SizedBox(
            height: 140,
            child: Center(child: Text('Lỗi: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection(BuildContext context, WidgetRef ref) {
    final expenseByCategory = ref.watch(expenseByCategoryProvider);
    final last7DaysData = ref.watch(last7DaysDataProvider);
    final summaryAsync = ref.watch(monthlySummaryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          summaryAsync.when(
            data: (summary) => ExpensePieChart(
              data: expenseByCategory,
              totalExpense: summary?.totalExpense ?? 0,
            ),
            loading: () => const ExpensePieChart(data: [], totalExpense: 0),
            error: (_, __) => const ExpensePieChart(data: [], totalExpense: 0),
          ),
          const SizedBox(height: 16),
          IncomeExpenseBarChart(data: last7DaysData),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (recentTransactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Chưa có giao dịch nào',
              subtitle: 'Thêm giao dịch đầu tiên của bạn',
            ),
          )
        else
          categoriesAsync.when(
            data: (categories) {
              final categoryMap = {for (var c in categories) c.id: c};
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recentTransactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  final category = categoryMap[transaction.categoryId];
                  return TransactionTile(
                    transaction: transaction,
                    category: category,
                    onTap: () {},
                  );
                },
              );
            },
            loading: () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TransactionTileShimmer(),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
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
