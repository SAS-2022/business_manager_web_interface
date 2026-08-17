import 'package:business_manager_web_ui/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  int get startMillis => start.millisecondsSinceEpoch;
  int get endMillis => end.millisecondsSinceEpoch;

  @override
  String toString() {
    return '${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}';
  }
}

class DateRangeHelper {
  /// Get the list of available period options (translated)
  static List<String> getPeriodOptions(AppLocalizations? appLoc) {
    return [
      appLoc?.today ?? 'Today',
      appLoc?.yesterday ?? 'Yesterday',
      appLoc?.thisWeek ?? 'This Week',
      appLoc?.lastWeek ?? 'Last Week',
      appLoc?.thisMonth ?? 'This Month',
      appLoc?.lastMonth ?? 'Last Month',
      appLoc?.thisYear ?? 'This Year',
      appLoc?.lastYear ?? 'Last Year',
    ];
  }

  /// Get date range based on selected period string (translated)
  static DateRange getDateRangeFromString(
      String period, AppLocalizations? appLoc) {
    // Handle both original English and translated strings
    if (period == (appLoc?.today ?? 'Today')) return _getTodayRange();
    if (period == (appLoc?.yesterday ?? 'Yesterday')) {
      return _getYesterdayRange();
    }
    if (period == (appLoc?.thisWeek ?? 'This Week')) return _getThisWeekRange();
    if (period == (appLoc?.lastWeek ?? 'Last Week')) return _getLastWeekRange();
    if (period == (appLoc?.thisMonth ?? 'This Month')) {
      return _getThisMonthRange();
    }
    if (period == (appLoc?.lastMonth ?? 'Last Month')) {
      return _getLastMonthRange();
    }
    if (period == (appLoc?.thisYear ?? 'This Year')) return _getThisYearRange();
    if (period == (appLoc?.lastYear ?? 'Last Year')) return _getLastYearRange();

    // Fallback to English comparison if translation not found
    return _getDateRangeFromEnglishString(period);
  }

  /// Fallback method using English strings
  static DateRange _getDateRangeFromEnglishString(String period) {
    switch (period) {
      case 'Today':
        return _getTodayRange();
      case 'Yesterday':
        return _getYesterdayRange();
      case 'This Week':
        return _getThisWeekRange();
      case 'Last Week':
        return _getLastWeekRange();
      case 'This Month':
        return _getThisMonthRange();
      case 'Last Month':
        return _getLastMonthRange();
      case 'This Year':
        return _getThisYearRange();
      case 'Last Year':
        return _getLastYearRange();
      default:
        throw ArgumentError('Invalid period: $period');
    }
  }

  /// Get millisecond timestamps directly
  static Map<String, int> getDateRangeMillis(
      String period, AppLocalizations? appLoc) {
    final range = getDateRangeFromString(period, appLoc);
    return {
      'start': range.startMillis,
      'end': range.endMillis,
    };
  }

  /// Individual range methods
  static DateRange _getTodayRange() {
    final now = DateTime.now();
    return DateRange(
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
  }

  static DateRange _getYesterdayRange() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return DateRange(
      DateTime(yesterday.year, yesterday.month, yesterday.day),
      DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999),
    );
  }

  static DateRange _getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return DateRange(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59, 999),
    );
  }

  static DateRange _getLastWeekRange() {
    final now = DateTime.now();
    final startOfLastWeek = now.subtract(Duration(days: now.weekday + 6));
    final endOfLastWeek = startOfLastWeek.add(const Duration(days: 6));
    return DateRange(
      DateTime(
          startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day),
      DateTime(endOfLastWeek.year, endOfLastWeek.month, endOfLastWeek.day, 23,
          59, 59, 999),
    );
  }

  static DateRange _getThisMonthRange() {
    final now = DateTime.now();
    return DateRange(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999),
    );
  }

  static DateRange _getLastMonthRange() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    return DateRange(
      DateTime(lastMonth.year, lastMonth.month, 1),
      DateTime(lastMonth.year, lastMonth.month + 1, 0, 23, 59, 59, 999),
    );
  }

  static DateRange _getThisYearRange() {
    final now = DateTime.now();
    return DateRange(
      DateTime(now.year, 1, 1),
      DateTime(now.year, 12, 31, 23, 59, 59, 999),
    );
  }

  static DateRange _getLastYearRange() {
    final now = DateTime.now();
    return DateRange(
      DateTime(now.year - 1, 1, 1),
      DateTime(now.year - 1, 12, 31, 23, 59, 59, 999),
    );
  }
}
