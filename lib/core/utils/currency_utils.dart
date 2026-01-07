import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String format(double amount, String currencyCode) {
    final formatter = _getFormatter(currencyCode);
    return formatter.format(amount);
  }

  static NumberFormat _getFormatter(String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        );
      case 'USD':
        return NumberFormat.currency(
          locale: 'en_US',
          symbol: '\$',
          decimalDigits: 2,
        );
      case 'EUR':
        return NumberFormat.currency(
          locale: 'de_DE',
          symbol: '€',
          decimalDigits: 2,
        );
      case 'JPY':
        return NumberFormat.currency(
          locale: 'ja_JP',
          symbol: '¥',
          decimalDigits: 0,
        );
      case 'GBP':
        return NumberFormat.currency(
          locale: 'en_GB',
          symbol: '£',
          decimalDigits: 2,
        );
      case 'CNY':
        return NumberFormat.currency(
          locale: 'zh_CN',
          symbol: '¥',
          decimalDigits: 2,
        );
      case 'KRW':
        return NumberFormat.currency(
          locale: 'ko_KR',
          symbol: '₩',
          decimalDigits: 0,
        );
      default:
        return NumberFormat.currency(
          locale: 'vi_VN',
          symbol: currencyCode,
          decimalDigits: 0,
        );
    }
  }

  static String getCurrencySymbol(String currencyCode) {
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
