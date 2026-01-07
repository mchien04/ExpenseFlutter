import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../../providers/backup_provider.dart';
import '../../theme/app_colors.dart';
import '../category/category_screens.dart';
import '../recurring/recurring_screens.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final backupState = ref.watch(backupNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Giao diện',
            isDark: isDark,
            children: [
              _buildThemeTile(context, ref, themeMode, isDark),
            ],
          ),
          _buildSection(
            title: 'Quản lý',
            isDark: isDark,
            children: [
              _buildSettingTile(
                icon: Icons.category,
                title: 'Danh mục',
                subtitle: 'Tạo và quản lý danh mục tùy chỉnh',
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriesScreen(),
                  ),
                ),
              ),
              _buildSettingTile(
                icon: Icons.repeat,
                title: 'Giao dịch định kỳ',
                subtitle: 'Quản lý giao dịch tự động hàng tháng',
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecurringTemplatesScreen(),
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'Dữ liệu',
            isDark: isDark,
            children: [
              _buildSettingTile(
                icon: Icons.upload_outlined,
                title: 'Xuất dữ liệu (JSON)',
                subtitle: 'Sao lưu toàn bộ dữ liệu',
                isDark: isDark,
                isLoading: backupState.isLoading,
                onTap: () =>
                    ref.read(backupNotifierProvider.notifier).exportToJson(),
              ),
              _buildSettingTile(
                icon: Icons.table_chart_outlined,
                title: 'Xuất giao dịch (CSV)',
                subtitle: 'Xuất dạng bảng tính Excel',
                isDark: isDark,
                isLoading: backupState.isLoading,
                onTap: () =>
                    ref.read(backupNotifierProvider.notifier).exportToCsv(),
              ),
              _buildSettingTile(
                icon: Icons.download_outlined,
                title: 'Khôi phục dữ liệu',
                subtitle: 'Nhập từ file JSON đã sao lưu',
                isDark: isDark,
                isLoading: backupState.isLoading,
                onTap: () => _confirmImport(context, ref),
              ),
              _buildSettingTile(
                icon: Icons.delete_forever_outlined,
                title: 'Xóa toàn bộ dữ liệu',
                subtitle: 'Xóa tất cả giao dịch, ví, danh mục',
                isDark: isDark,
                isDestructive: true,
                onTap: () => _confirmClearData(context, ref),
              ),
            ],
          ),
          _buildSection(
            title: 'Thông tin',
            isDark: isDark,
            children: [
              _buildSettingTile(
                icon: Icons.info_outline,
                title: 'Phiên bản',
                subtitle: '1.0.0',
                isDark: isDark,
              ),
            ],
          ),
          if (backupState.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                backupState.error!,
                style: TextStyle(color: Colors.red.shade400),
              ),
            ),
          if (backupState.successMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                backupState.successMessage!,
                style: TextStyle(color: Colors.green.shade400),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      title: Text(
        'Chế độ giao diện',
        style: TextStyle(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        _getThemeModeLabel(currentMode),
        style: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      onTap: () => _showThemeSelector(context, ref, currentMode),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Theo hệ thống';
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
    }
  }

  void _showThemeSelector(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Chế độ giao diện',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RadioListTile<ThemeMode>(
            title: const Text('Theo hệ thống'),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state = value!;
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sáng'),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state = value!;
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Tối'),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (value) {
              ref.read(themeModeProvider.notifier).state = value!;
              Navigator.pop(context);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    bool isDestructive = false,
    bool isLoading = false,
    VoidCallback? onTap,
  }) {
    final textColor = isDestructive
        ? Colors.red
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return ListTile(
      leading: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      onTap: isLoading ? null : onTap,
    );
  }

  void _confirmImport(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục dữ liệu?'),
        content: const Text(
          'Dữ liệu hiện tại sẽ bị ghi đè bởi dữ liệu từ file sao lưu. '
          'Bạn có chắc muốn tiếp tục?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(backupNotifierProvider.notifier).importFromJson();
            },
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa toàn bộ dữ liệu?'),
        content: const Text(
          'Tất cả giao dịch, ví, danh mục sẽ bị xóa vĩnh viễn. '
          'Hành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(backupNotifierProvider.notifier).clearAllData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}
