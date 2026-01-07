import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'vi_VN');
  static final DateFormat _dayMonthFormat = DateFormat('dd MMM', 'vi_VN');
  static final DateFormat _weekdayFormat = DateFormat('EEEE', 'vi_VN');
  static final DateFormat _shortWeekdayFormat = DateFormat('EEE', 'vi_VN');
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  static String formatDayMonth(DateTime date) => _dayMonthFormat.format(date);

  static String formatWeekday(DateTime date) => _weekdayFormat.format(date);

  static String formatShortWeekday(DateTime date) =>
      _shortWeekdayFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Hôm nay';
    } else if (difference == 1) {
      return 'Hôm qua';
    } else if (difference == -1) {
      return 'Ngày mai';
    } else if (difference > 1 && difference <= 7) {
      return '$difference ngày trước';
    } else if (difference < -1 && difference >= -7) {
      return 'Sau ${-difference} ngày';
    } else {
      return formatDate(date);
    }
  }

  static String formatGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Hôm nay - ${formatDate(date)}';
    } else if (difference == 1) {
      return 'Hôm qua - ${formatDate(date)}';
    } else {
      return '${formatWeekday(date)} - ${formatDate(date)}';
    }
  }
}
