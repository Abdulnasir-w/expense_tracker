import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility helpers for formatting [DateTime] values.
class DateFormatter {
  DateFormatter._();

  /// e.g. `06 Nov 2026`
  static String toDisplay(DateTime date) =>
      DateFormat(AppConstants.displayDateFormat).format(date);

  /// e.g. `Nov 2026`
  static String toMonth(DateTime date) =>
      DateFormat(AppConstants.displayMonthFormat).format(date);

  /// e.g. `2026-11-06` — used for storage/sorting keys.
  static String toStorage(DateTime date) =>
      DateFormat(AppConstants.storageDateFormat).format(date);

  /// e.g. `Today`, `Yesterday`, or `06 Nov 2026`.
  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return toDisplay(date);
  }
}
