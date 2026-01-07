import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../helpers/currency_formatter.dart';
import '../../helpers/vietnamese_ime_helper.dart';
import '../../providers/wallet_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/empty_state.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletsAsync = ref.watch(walletsWithBalanceProvider);
    final walletState = ref.watch(walletNotifierProvider);

    ref.listen(walletNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Chưa có ví nào',
                subtitle: 'Tạo ví đầu tiên để bắt đầu theo dõi chi tiêu',
                action: ElevatedButton.icon(
                  onPressed: () => _showUpsertWalletSheet(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo ví'),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            itemCount: wallets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = wallets[index];
              return _WalletTile(
                wallet: item.wallet,
                balance: item.balance,
                isDark: isDark,
                onTap: () => _showUpsertWalletSheet(
                  context,
                  ref,
                  wallet: item.wallet,
                ),
                onDelete: () => _confirmDelete(context, ref, item.wallet),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: walletState.isLoading
            ? null
            : () => _showUpsertWalletSheet(context, ref),
        child: walletState.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WalletEntity wallet,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa ví?'),
        content: Text(
          'Bạn có chắc muốn xóa ví "${wallet.name}"?\n'
          'Các giao dịch liên quan có thể bị ảnh hưởng.',
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

    final ok = await ref.read(walletNotifierProvider.notifier).deleteWallet(
          wallet.id,
        );

    if (!context.mounted) return;

    if (ok) {
      ref.invalidate(walletsWithBalanceProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa ví')),
      );
    }
  }

  void _showUpsertWalletSheet(
    BuildContext context,
    WidgetRef ref, {
    WalletEntity? wallet,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UpsertWalletSheet(wallet: wallet),
    ).then((value) {
      if (value == true) {
        ref.invalidate(walletsWithBalanceProvider);
      }
    });
  }
}

class _WalletTile extends StatelessWidget {
  final WalletEntity wallet;
  final double balance;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WalletTile({
    required this.wallet,
    required this.balance,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.cardDark : AppColors.surfaceLight;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : AppColors.primaryLight)
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color:
                      isDark ? AppColors.textPrimaryDark : AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wallet.allowNegativeBalance
                          ? 'Cho phép âm'
                          : 'Không cho phép âm',
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(balance,
                        currencyCode: wallet.currencyCode),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpsertWalletSheet extends ConsumerStatefulWidget {
  final WalletEntity? wallet;

  const _UpsertWalletSheet({this.wallet});

  @override
  ConsumerState<_UpsertWalletSheet> createState() => _UpsertWalletSheetState();
}

class _UpsertWalletSheetState extends ConsumerState<_UpsertWalletSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _initialBalanceController;

  late bool _allowNegativeBalance;
  late String _currencyCode;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _initialBalanceController =
        TextEditingController(text: (widget.wallet?.initialBalance ?? 0).toStringAsFixed(0));

    _allowNegativeBalance = widget.wallet?.allowNegativeBalance ?? true;
    _currencyCode = widget.wallet?.currencyCode ?? AppConstants.defaultCurrencyCode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(walletNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.wallet == null ? 'Tạo ví' : 'Chỉnh sửa ví',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                inputFormatters: [IMEPreservingFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Tên ví',
                  hintText: 'VD: Tiền mặt, Momo, Ngân hàng...',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên ví';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số dư ban đầu',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = double.tryParse(value.replaceAll(',', '').trim());
                  if (parsed == null) {
                    return 'Số dư không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currencyCode,
                decoration: const InputDecoration(labelText: 'Tiền tệ'),
                items: AppConstants.supportedCurrencies
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _currencyCode = value);
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _allowNegativeBalance,
                onChanged: (v) => setState(() => _allowNegativeBalance = v),
                title: const Text('Cho phép số dư âm'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.wallet == null ? 'Tạo ví' : 'Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final initialBalance = double.tryParse(
          _initialBalanceController.text.replaceAll(',', '').trim(),
        ) ??
        0.0;

    bool ok;

    if (widget.wallet == null) {
      ok = await ref.read(walletNotifierProvider.notifier).createWallet(
            name: name,
            initialBalance: initialBalance,
            allowNegativeBalance: _allowNegativeBalance,
            currencyCode: _currencyCode,
          );
    } else {
      final updated = widget.wallet!.copyWith(
        name: name,
        initialBalance: initialBalance,
        allowNegativeBalance: _allowNegativeBalance,
        currencyCode: _currencyCode,
        updatedAt: DateTime.now(),
      );

      ok = await ref.read(walletNotifierProvider.notifier).updateWallet(updated);
    }

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
    }
  }
}
