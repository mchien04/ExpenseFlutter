import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MM/yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  static String formatIso(DateTime date) => _isoFormat.format(date);

  static DateTime parseIso(String dateStr) => DateTime.parse(dateStr);

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = startOfDay(now);
    final targetDate = startOfDay(date);
    return targetDate.isAfter(today);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}
