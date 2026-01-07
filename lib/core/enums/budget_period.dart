enum BudgetPeriod {
  monthly;

  String get displayName {
    switch (this) {
      case BudgetPeriod.monthly:
        return 'Hàng tháng';
    }
  }

  static BudgetPeriod fromString(String value) {
    return BudgetPeriod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BudgetPeriod.monthly,
    );
  }
}
