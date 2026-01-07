import 'package:equatable/equatable.dart';

import '../../core/enums/enums.dart';

class RecurringTemplateEntity extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String walletId;
  final RecurringFrequency frequency;
  final DateTime nextExecutionDate;
  final bool isActive;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringTemplateEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.frequency,
    required this.nextExecutionDate,
    this.isActive = true,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringTemplateEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? walletId,
    RecurringFrequency? frequency,
    DateTime? nextExecutionDate,
    bool? isActive,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTemplateEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      frequency: frequency ?? this.frequency,
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
      isActive: isActive ?? this.isActive,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DateTime calculateNextExecutionDate() {
    switch (frequency) {
      case RecurringFrequency.daily:
        return nextExecutionDate.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return nextExecutionDate.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        return DateTime(
          nextExecutionDate.year,
          nextExecutionDate.month + 1,
          nextExecutionDate.day,
        );
    }
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        categoryId,
        walletId,
        frequency,
        nextExecutionDate,
        isActive,
        note,
        createdAt,
        updatedAt,
      ];
}
