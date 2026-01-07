import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_category_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.category_outlined,
                title: 'Chưa có danh mục',
                subtitle: 'Tạo danh mục để phân loại giao dịch',
                action: ElevatedButton.icon(
                  onPressed: () => _navigateToAdd(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo danh mục'),
                ),
              ),
            );
          }

          final expenseCategories =
              categories.where((c) => c.type == TransactionType.expense).toList();
          final incomeCategories =
              categories.where((c) => c.type == TransactionType.income).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              if (expenseCategories.isNotEmpty) ...[
                _buildSectionHeader('Chi tiêu', Icons.arrow_upward_rounded,
                    AppColors.expense, isDark),
                const SizedBox(height: 12),
                ...expenseCategories.map((category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CategoryTile(
                        category: category,
                        isDark: isDark,
                        onTap: () => _navigateToEdit(context, category),
                        onDelete: () => _confirmDelete(context, ref, category),
                      ),
                    )),
                const SizedBox(height: 20),
              ],
              if (incomeCategories.isNotEmpty) ...[
                _buildSectionHeader('Thu nhập', Icons.arrow_downward_rounded,
                    AppColors.income, isDark),
                const SizedBox(height: 12),
                ...incomeCategories.map((category) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CategoryTile(
                        category: category,
                        isDark: isDark,
                        onTap: () => _navigateToEdit(context, category),
                        onDelete: () => _confirmDelete(context, ref, category),
                      ),
                    )),
              ],
            ],
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

  Widget _buildSectionHeader(
      String title, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditCategoryScreen(),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, CategoryEntity category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCategoryScreen(category: category),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text(
          'Bạn có chắc muốn xóa danh mục "${category.name}"?\n'
          'Các giao dịch đã có sẽ không bị xóa.',
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
        .read(categoryNotifierProvider.notifier)
        .deleteCategory(category.id);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa danh mục')),
      );
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(category.icon, color: category.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              iconSize: 20,
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
