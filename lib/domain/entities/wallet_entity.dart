import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String name;
  final double initialBalance;
  final bool allowNegativeBalance;
  final String currencyCode;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletEntity({
    required this.id,
    required this.name,
    this.initialBalance = 0.0,
    this.allowNegativeBalance = true,
    this.currencyCode = 'VND',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  WalletEntity copyWith({
    String? id,
    String? name,
    double? initialBalance,
    bool? allowNegativeBalance,
    String? currencyCode,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      allowNegativeBalance: allowNegativeBalance ?? this.allowNegativeBalance,
      currencyCode: currencyCode ?? this.currencyCode,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        initialBalance,
        allowNegativeBalance,
        currencyCode,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
