enum TransactionStatus {
  pending,
  completed;

  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Đang chờ';
      case TransactionStatus.completed:
        return 'Hoàn thành';
    }
  }

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}
