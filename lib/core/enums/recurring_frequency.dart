enum RecurringFrequency {
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case RecurringFrequency.daily:
        return 'Hàng ngày';
      case RecurringFrequency.weekly:
        return 'Hàng tuần';
      case RecurringFrequency.monthly:
        return 'Hàng tháng';
    }
  }

  int get daysInterval {
    switch (this) {
      case RecurringFrequency.daily:
        return 1;
      case RecurringFrequency.weekly:
        return 7;
      case RecurringFrequency.monthly:
        return 30;
    }
  }

  static RecurringFrequency fromString(String value) {
    return RecurringFrequency.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecurringFrequency.monthly,
    );
  }
}
