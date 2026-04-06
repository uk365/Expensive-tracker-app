import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime get startOfThisWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  static DateTime get startOfThisMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  static DateTime get startOfThisYear {
    return DateTime(DateTime.now().year, 1, 1);
  }

  static DateTime get endOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  static DateTime get endOfThisMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  static List<DateTime> getLast6Months() {
    final months = <DateTime>[];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }
    return months;
  }

  static List<DateTime> getLast12Months() {
    final months = <DateTime>[];
    final now = DateTime.now();
    for (int i = 11; i >= 0; i--) {
      months.add(DateTime(now.year, now.month - i, 1));
    }
    return months;
  }

  static String formatMonthYear(DateTime dt) => DateFormat('MMM yy').format(dt);

  static DateTimeRange periodRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'day':
        return DateTimeRange(start: startOfToday, end: endOfToday);
      case 'week':
        return DateTimeRange(
          start: startOfThisWeek,
          end: startOfThisWeek.add(const Duration(days: 6)),
        );
      case 'month':
        return DateTimeRange(start: startOfThisMonth, end: endOfThisMonth);
      case 'year':
        return DateTimeRange(
          start: startOfThisYear,
          end: DateTime(now.year, 12, 31),
        );
      default:
        return DateTimeRange(start: startOfThisMonth, end: endOfThisMonth);
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}
