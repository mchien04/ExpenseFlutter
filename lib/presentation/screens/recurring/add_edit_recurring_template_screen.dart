import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/enums.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/recurring_template_entity.dart';
import '../../helpers/date_formatter.dart';
import '../../helpers/vietnamese_ime_helper.dart';
import '../../providers/category_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';

class AddEditRecurringTemplateScreen extends ConsumerStatefulWidget {
  final RecurringTemplateEntity? template;

  const AddEditRecurringTemplateScreen({
    super.key,
    this.template,
  });

  @override
  ConsumerState<AddEditRecurringTemplateScreen> createState() =>
      _AddEditRecurringTemplateScreenState();
}

class _AddEditRecurringTemplateScreenState
    extends ConsumerState<AddEditRecurringTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  late RecurringFrequency _selectedFrequency;
  late DateTime _nextExecutionDate;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.template!;
      _amountController.text = t.amount.toStringAsFixed(0);
      _noteController.text = t.note;
      _selectedType = t.type;
      _selectedCategoryId = t.categoryId;
      _selectedWalletId = t.walletId;
      _selectedFrequency = t.frequency;
      _nextExecutionDate = t.nextExecutionDate;
      _isActive = t.isActive;
    } else {
      _selectedType = TransactionType.expense;
      _selectedFrequency = RecurringFrequency.monthly;
      _nextExecutionDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa giao dịch định kỳ' : 'Tạo giao dịch định kỳ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTypeSelector(isDark),
            const SizedBox(height: 20),
            _buildAmountField(isDark),
            const SizedBox(height: 20),
            _buildCategorySelector(isDark),
            const SizedBox(height: 20),
            _buildWalletSelector(isDark),
            const SizedBox(height: 20),
            _buildFrequencySelector(isDark),
            const SizedBox(height: 20),
            _buildNextExecutionDatePicker(isDark),
            const SizedBox(height: 20),
            _buildNoteField(isDark),
            const SizedBox(height: 20),
            _buildActiveSwitch(isDark),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            if (isEditing) ...[
              const SizedBox(height: 12),
              _buildDeleteButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return Column(
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
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.expense,
                label: 'Chi tiêu',
                icon: Icons.arrow_upward_rounded,
                color: AppColors.expense,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                type: TransactionType.income,
                label: 'Thu nhập',
                icon: Icons.arrow_downward_rounded,
                color: AppColors.income,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _selectedCategoryId = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số tiền',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandsSeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'VND',
            prefixIcon: Icon(
              _selectedType == TransactionType.expense
                  ? Icons.remove_circle_outline
                  : Icons.add_circle_outline,
              color: _selectedType == TransactionType.expense
                  ? AppColors.expense
                  : AppColors.income,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập số tiền';
            }
            final amount = double.tryParse(value.replaceAll('.', ''));
            if (amount == null || amount <= 0) {
              return 'Số tiền phải lớn hơn 0';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh mục',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        categoriesAsync.when(
          data: (categories) {
            final filteredCategories =
                categories.where((c) => c.type == _selectedType).toList();

            if (filteredCategories.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Chưa có danh mục'),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredCategories.map((category) {
                return _buildCategoryChip(category, isDark);
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Lỗi: $e'),
        ),
        if (_selectedCategoryId == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Vui lòng chọn danh mục',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip(CategoryEntity category, bool isDark) {
    final isSelected = _selectedCategoryId == category.id;
    final color = category.color;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = category.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector(bool isDark) {
    final walletsAsync = ref.watch(walletsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 8),
        walletsAsync.when(
          data: (wallets) {
            if (wallets.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Chưa có ví'),
              );
            }

            return DropdownButtonFormField<String>(
              value: _selectedWalletId,
              decoration: const InputDecoration(
                hintText: 'Chọn ví',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: wallets
                  .map((w) => DropdownMenuItem(
                        value: w.id,
                        child: Text(w.name),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedWalletId = value),
              validator: (value) {
                if (value == null) return 'Vui lòng chọn ví';
                return null;
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Lỗi: $e'),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tần suất',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurringFrequency>(
          value: _selectedFrequency,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.repeat),
          ),
          items: RecurringFrequency.values
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(_getFrequencyText(f)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedFrequency = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNextExecutionDatePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày thực hiện kế tiếp',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectNextExecutionDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormatter.formatDate(_nextExecutionDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ghi chú (không bắt buộc)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          inputFormatters: [IMEPreservingFormatter()],
          decoration: const InputDecoration(
            hintText: 'Thêm ghi chú...',
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSwitch(bool isDark) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: _isActive,
      onChanged: (v) => setState(() => _isActive = v),
      title: const Text('Kích hoạt'),
      subtitle: const Text('Tự động tạo giao dịch theo lịch'),
    );
  }

  Widget _buildSubmitButton() {
    final color = _selectedType == TransactionType.expense
        ? AppColors.expense
        : AppColors.income;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Lưu thay đổi' : 'Tạo giao dịch định kỳ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _confirmDelete,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Xóa giao dịch định kỳ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectNextExecutionDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextExecutionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() => _nextExecutionDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount =
        double.parse(_amountController.text.replaceAll('.', '').trim());
    final note = _noteController.text.trim();

    bool success;

    if (isEditing) {
      final updated = widget.template!.copyWith(
        amount: amount,
        type: _selectedType,
        categoryId: _selectedCategoryId,
        walletId: _selectedWalletId,
        frequency: _selectedFrequency,
        nextExecutionDate: _nextExecutionDate,
        isActive: _isActive,
        note: note,
        updatedAt: DateTime.now(),
      );

      success =
          await ref.read(recurringNotifierProvider.notifier).updateTemplate(updated);
    } else {
      success = await ref.read(recurringNotifierProvider.notifier).createTemplate(
            amount: amount,
            type: _selectedType,
            categoryId: _selectedCategoryId!,
            walletId: _selectedWalletId!,
            frequency: _selectedFrequency,
            nextExecutionDate: _nextExecutionDate,
            note: note,
          );
    }

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _confirmDelete() async {
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

    if (result != true) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(recurringNotifierProvider.notifier)
        .deleteTemplate(widget.template!.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    }
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

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (VietnameseIMEHelper.isComposing(newValue)) {
      return newValue;
    }

    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll('.', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
