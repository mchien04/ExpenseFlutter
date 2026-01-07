enum TransactionType {
  income,
  expense;

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Thu nhập';
      case TransactionType.expense:
        return 'Chi tiêu';
    }
  }

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
