import 'package:equatable/equatable.dart';

import '../../core/enums/enums.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String walletId;
  final DateTime date;
  final TransactionStatus status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.date,
    this.status = TransactionStatus.completed,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? walletId,
    DateTime? date,
    TransactionStatus? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        categoryId,
        walletId,
        date,
        status,
        note,
        createdAt,
        updatedAt,
      ];
}
