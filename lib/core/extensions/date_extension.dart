import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String formatDate({String pattern = 'MMM d, yyyy'}) =>
      DateFormat(pattern).format(this);

  String formatShort() => DateFormat('MMM d').format(this);

  String formatFull() => DateFormat('MMMM d, yyyy').format(this);

  String formatMonthYear() => DateFormat('MMM yyyy').format(this);

  String formatIso() => toIso8601String().substring(0, 10);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  bool get isThisYear {
    return year == DateTime.now().year;
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return formatShort();
    }
  }

  int get daysUntil => difference(DateTime.now()).inDays;

  bool get isOverdue => isBefore(DateTime.now());

  bool get isWithinDays7 {
    final now = DateTime.now();
    final diff = difference(now).inDays;
    return diff >= 0 && diff <= 7;
  }

  bool get isWithinDays30 {
    final now = DateTime.now();
    final diff = difference(now).inDays;
    return diff >= 0 && diff <= 30;
  }
}

extension NullableDateExtension on DateTime? {
  String formatOrDash({String pattern = 'MMM d, yyyy'}) {
    if (this == null) return '—';
    return DateFormat(pattern).format(this!);
  }
}
