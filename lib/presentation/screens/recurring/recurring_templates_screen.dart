import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../domain/entities/recurring_template_entity.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/date_formatter.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_recurring_template_screen.dart';

class RecurringTemplatesScreen extends ConsumerWidget {
  const RecurringTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templatesAsync = ref.watch(recurringTemplatesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch định kỳ'),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.repeat_outlined,
                title: 'Chưa có giao dịch định kỳ',
                subtitle: 'Tạo giao dịch định kỳ để tự động ghi nhận chi tiêu hàng tháng',
                action: ElevatedButton.icon(
                  onPressed: () => _navigateToAdd(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo mới'),
                ),
              ),
            );
          }

          return categoriesAsync.when(
            data: (categories) {
              final categoryMap = {for (var c in categories) c.id: c};
              
              return walletsAsync.when(
                data: (wallets) {
                  final walletMap = {for (var w in wallets) w.id: w};
                  
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final category = categoryMap[template.categoryId];
                      final wallet = walletMap[template.walletId];
                      
                      return _RecurringTemplateTile(
                        template: template,
                        categoryName: category?.name ?? 'Không xác định',
                        categoryIcon: category?.icon ?? Icons.help_outline,
                        categoryColor: category?.color ?? Colors.grey,
                        walletName: wallet?.name ?? 'Không xác định',
                        isDark: isDark,
                        onTap: () => _navigateToEdit(context, template),
                        onToggle: () => _toggleActive(context, ref, template),
                        onDelete: () => _confirmDelete(context, ref, template),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi: $e')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Lỗi: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditRecurringTemplateScreen(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, RecurringTemplateEntity template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditRecurringTemplateScreen(template: template),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    RecurringTemplateEntity template,
  ) async {
    final notifier = ref.read(recurringNotifierProvider.notifier);
    final success = template.isActive
        ? await notifier.deactivateTemplate(template.id)
        : await notifier.activateTemplate(template.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            template.isActive ? 'Đã tắt giao dịch định kỳ' : 'Đã bật giao dịch định kỳ',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTemplateEntity template,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch định kỳ?'),
        content: const Text(
          'Bạn có chắc muốn xóa giao dịch định kỳ này?\n'
          'Các giao dịch đã tạo sẽ không bị ảnh hưởng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;

    final success = await ref
        .read(recurringNotifierProvider.notifier)
        .deleteTemplate(template.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa giao dịch định kỳ')),
      );
    }
  }
}

class _RecurringTemplateTile extends StatelessWidget {
  final RecurringTemplateEntity template;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final String walletName;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _RecurringTemplateTile({
    required this.template,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.walletName,
    required this.isDark,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = template.type == TransactionType.expense;
    final amountColor = isExpense ? AppColors.expense : AppColors.income;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: template.isActive
                ? Colors.transparent
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        walletName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.formatCompact(template.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
            if (template.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                template.note,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  _getFrequencyText(template.frequency),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Kế tiếp: ${DateFormatter.formatDate(template.nextExecutionDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: template.isActive,
                  onChanged: (_) => onToggle(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyText(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Hàng ngày';
      case RecurringFrequency.weekly:
        return 'Hàng tuần';
      case RecurringFrequency.monthly:
        return 'Hàng tháng';
    }
  }
}
