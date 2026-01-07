import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final Map<String, NumberFormat> _formatters = {};

  static NumberFormat _getFormatter(String currencyCode) {
    if (_formatters.containsKey(currencyCode)) {
      return _formatters[currencyCode]!;
    }

    NumberFormat formatter;
    switch (currencyCode) {
      case 'VND':
        formatter = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        );
        break;
      case 'USD':
        formatter = NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        );
        break;
      case 'EUR':
        formatter = NumberFormat.currency(
          locale: 'de_DE',
          symbol: '€',
          decimalDigits: 2,
        );
        break;
      case 'JPY':
        formatter = NumberFormat.currency(
          locale: 'ja_JP',
          symbol: '¥',
          decimalDigits: 0,
        );
        break;
      case 'GBP':
        formatter = NumberFormat.currency(
          locale: 'en_GB',
          symbol: '£',
          decimalDigits: 2,
        );
        break;
      case 'CNY':
        formatter = NumberFormat.currency(
          locale: 'zh_CN',
          symbol: '¥',
          decimalDigits: 2,
        );
        break;
      case 'KRW':
        formatter = NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        );
        break;
      default:
        formatter = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: currencyCode,
          decimalDigits: 0,
        );
    }

    _formatters[currencyCode] = formatter;
    return formatter;
  }

  static String format(double amount, {String currencyCode = 'VND'}) {
    return _getFormatter(currencyCode).format(amount);
  }

  static String formatCompact(double amount, {String currencyCode = 'VND'}) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currencyCode: currencyCode);
  }

  static String formatWithSign(
    double amount, {
    String currencyCode = 'VND',
    bool isExpense = false,
  }) {
    final formatted = format(amount.abs(), currencyCode: currencyCode);
    if (isExpense) {
      return '-$formatted';
    }
    return '+$formatted';
  }

  static String getSymbol(String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return '₫';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'GBP':
        return '£';
      case 'KRW':
        return '₩';
      default:
        return currencyCode;
    }
  }
}
