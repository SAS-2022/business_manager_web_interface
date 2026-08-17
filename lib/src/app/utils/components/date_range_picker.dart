import 'package:flutter/material.dart';

class DateRangePickerUtil {
  static Future<DateTimeRange?> show({
    required BuildContext context,
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
    Color? primaryColor,
    String? saveText,
    String? cancelText,
    String? helpText,
  }) async {
    final locale = Localizations.localeOf(context);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
      initialDateRange: initialDateRange,
      saveText: saveText,
      cancelText: cancelText,
      helpText: helpText,
      locale: locale,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            // colorScheme:  ColorScheme.light(
            //   primary: primaryColor ?? Theme.of(context).primaryColor,
            //   onPrimary: Colors.white,
            //   surface: Colors.white,
            //   onSurface: Colors.black,
            // ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.white, // Text field background
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final DateTime adjustedStart = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
      );

      final DateTime adjustedEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23, // hour
        59, // minute
        59, // second
        999, // millisecond
      );

      return DateTimeRange(start: adjustedStart, end: adjustedEnd);
    }
    return picked;
  }

  Future<void> selectTimePeriod() async {
    //implement selecting a time period through a dropdown list, a user can select one of the following options:
    // Today, This Week, last week, This Month, last month, This Year and last year
  }
}
