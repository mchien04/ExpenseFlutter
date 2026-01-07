import 'package:flutter/material.dart';

import '../helpers/currency_formatter.dart';
import '../theme/app_colors.dart';

class WalletCard extends StatelessWidget {
  final String name;
  final double balance;
  final String currencyCode;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool isSelected;

  const WalletCard({
    super.key,
    required this.name,
    required this.balance,
    this.currencyCode = 'VND',
    this.backgroundColor,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.cardDark : AppColors.primaryLight);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              bgColor,
              bgColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: bgColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số dư',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CurrencyFormatter.format(balance,
                          currencyCode: currencyCode),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: balance.abs() >= 1000000000 ? 15 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class WalletCardList extends StatelessWidget {
  final List<WalletCardData> wallets;
  final String? selectedWalletId;
  final Function(String walletId)? onWalletTap;
  final double height;

  const WalletCardList({
    super.key,
    required this.wallets,
    this.selectedWalletId,
    this.onWalletTap,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Chưa có ví nào',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return WalletCard(
            name: wallet.name,
            balance: wallet.balance,
            currencyCode: wallet.currencyCode,
            backgroundColor: _getWalletColor(index),
            isSelected: wallet.id == selectedWalletId,
            onTap: () => onWalletTap?.call(wallet.id),
          );
        },
      ),
    );
  }

  Color _getWalletColor(int index) {
    final colors = [
      AppColors.primaryLight,
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
    ];
    return colors[index % colors.length];
  }
}

class WalletCardData {
  final String id;
  final String name;
  final double balance;
  final String currencyCode;

  WalletCardData({
    required this.id,
    required this.name,
    required this.balance,
    this.currencyCode = 'VND',
  });
}
