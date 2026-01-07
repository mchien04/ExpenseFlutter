class AppConstants {
  AppConstants._();

  static const String appName = 'Expense Tracker';
  static const String databaseName = 'expense_tracker.db';
  static const int databaseVersion = 1;

  static const String defaultCurrencyCode = 'VND';

  static const List<String> supportedCurrencies = [
    'VND',
    'USD',
    'EUR',
    'JPY',
    'GBP',
    'CNY',
    'KRW',
  ];
}
