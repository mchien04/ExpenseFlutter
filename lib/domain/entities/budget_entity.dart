import 'package:equatable/equatable.dart';

import '../../core/enums/enums.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String categoryId;
  final double limitAmount;
  final BudgetPeriod period;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.period = BudgetPeriod.monthly,
    required this.createdAt,
    required this.updatedAt,
  });

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    BudgetPeriod? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        limitAmount,
        period,
        createdAt,
        updatedAt,
      ];
}
