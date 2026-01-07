import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../helpers/date_formatter.dart';
import '../../helpers/vietnamese_ime_helper.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_transaction_screen.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final filterTypeProvider = StateProvider<TransactionType?>((ref) => null);
final filterWalletIdProvider = StateProvider<String?>((ref) => null);

final filteredTransactionsProvider =
    Provider.autoDispose<List<TransactionEntity>>((ref) {
  final transactionsAsync = ref.watch(monthlyTransactionsProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final filterType = ref.watch(filterTypeProvider);
  final filterWalletId = ref.watch(filterWalletIdProvider);

  return transactionsAsync.when(
    data: (transactions) {
      var filtered = transactions;

      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((t) => t.note.toLowerCase().contains(searchQuery))
            .toList();
      }

      if (filterType != null) {
        filtered = filtered.where((t) => t.type == filterType).toList();
      }

      if (filterWalletId != null) {
        filtered =
            filtered.where((t) => t.walletId == filterWalletId).toList();
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMonth = ref.watch(selectedMonthProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField(isDark)
            : GestureDetector(
                onTap: () => _showMonthPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(DateFormatter.formatMonthYear(selectedMonth)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 20),
                  ],
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(searchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final categoryMap = {for (var c in categories) c.id: c};
          return _buildTransactionList(transactions, categoryMap, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField(bool isDark) {
    return TextField(
      controller: _searchController,
      autofocus: true,
      inputFormatters: [IMEPreservingFormatter()],
      decoration: InputDecoration(
        hintText: 'Tìm theo ghi chú...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      style: TextStyle(
        color:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      onChanged: (value) {
        ref.read(searchQueryProvider.notifier).state = value;
      },
    );
  }

  Widget _buildTransactionList(
    List<TransactionEntity> transactions,
    Map<String, CategoryEntity> categoryMap,
    bool isDark,
  ) {
    if (transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Không có giao dịch nào',
        subtitle: 'Thử thay đổi bộ lọc hoặc thêm giao dịch mới',
      );
    }

    final groupedTransactions = _groupByDate(transactions);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final group = groupedTransactions[index];
        return _buildDateGroup(group, categoryMap, isDark);
      },
    );
  }

  List<_DateGroup> _groupByDate(List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> grouped = {};

    for (final t in transactions) {
      final dateKey = DateFormatter.formatDate(t.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(t);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = grouped[a]!.first.date;
        final dateB = grouped[b]!.first.date;
        return dateB.compareTo(dateA);
      });

    return sortedKeys.map((key) {
      final items = grouped[key]!;
      return _DateGroup(
        date: items.first.date,
        transactions: items,
      );
    }).toList();
  }

  Widget _buildDateGroup(
    _DateGroup group,
    Map<String, CategoryEntity> categoryMap,
    bool isDark,
  ) {
    double totalIncome = 0;
    double totalExpense = 0;

    for (final t in group.transactions) {
      if (t.type == TransactionType.income) {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.formatGroupHeader(group.date),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Row(
                children: [
                  if (totalIncome > 0)
                    Text(
                      '+${_formatCompact(totalIncome)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.income,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (totalIncome > 0 && totalExpense > 0)
                    const SizedBox(width: 8),
                  if (totalExpense > 0)
                    Text(
                      '-${_formatCompact(totalExpense)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.expense,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        ...group.transactions.map((t) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TransactionTile(
              transaction: t,
              category: categoryMap[t.categoryId],
              onTap: () => _navigateToEditTransaction(context, t),
            ),
          );
        }),
      ],
    );
  }

  String _formatCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }

  void _showMonthPicker(BuildContext context) async {
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterBottomSheet(),
    );
  }

  void _navigateToAddTransaction(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditTransactionScreen(),
      ),
    );
    if (result == true) {
      ref.invalidate(monthlyTransactionsProvider);
    }
  }

  void _navigateToEditTransaction(
    BuildContext context,
    TransactionEntity transaction,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: transaction),
      ),
    );
    if (result == true) {
      ref.invalidate(monthlyTransactionsProvider);
    }
  }
}

class _DateGroup {
  final DateTime date;
  final List<TransactionEntity> transactions;

  _DateGroup({required this.date, required this.transactions});
}

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filterType = ref.watch(filterTypeProvider);
    final filterWalletId = ref.watch(filterWalletIdProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loại giao dịch',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(
                      label: 'Tất cả',
                      isSelected: filterType == null,
                      onTap: () =>
                          ref.read(filterTypeProvider.notifier).state = null,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Chi tiêu',
                      isSelected: filterType == TransactionType.expense,
                      color: AppColors.expense,
                      onTap: () => ref.read(filterTypeProvider.notifier).state =
                          TransactionType.expense,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Thu nhập',
                      isSelected: filterType == TransactionType.income,
                      color: AppColors.income,
                      onTap: () => ref.read(filterTypeProvider.notifier).state =
                          TransactionType.income,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Ví',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                walletsAsync.when(
                  data: (wallets) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          label: 'Tất cả',
                          isSelected: filterWalletId == null,
                          onTap: () => ref
                              .read(filterWalletIdProvider.notifier)
                              .state = null,
                        ),
                        ...wallets.map((w) => _buildFilterChip(
                              label: w.name,
                              isSelected: filterWalletId == w.id,
                              onTap: () => ref
                                  .read(filterWalletIdProvider.notifier)
                                  .state = w.id,
                            )),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Lỗi: $e'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(filterTypeProvider.notifier).state = null;
                      ref.read(filterWalletIdProvider.notifier).state = null;
                    },
                    child: const Text('Xóa bộ lọc'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : chipColor.withAlpha(75),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
