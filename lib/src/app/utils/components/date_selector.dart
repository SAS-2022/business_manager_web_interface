import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScrollingDateSelector extends StatefulWidget {
  final ValueChanged<DateTime>? onDateChanged;
  final DateTime? initialDate;

  const ScrollingDateSelector({
    super.key,
    this.onDateChanged,
    this.initialDate,
  });

  @override
  State<ScrollingDateSelector> createState() => _ScrollingDateSelectorState();
}

class _ScrollingDateSelectorState extends State<ScrollingDateSelector> {
  late DateTime _selectedDate;
  late DateTime _currentDate;
  final PageController _monthController = PageController();
  final FixedExtentScrollController _dayController =
      FixedExtentScrollController();
  final FixedExtentScrollController _yearController =
      FixedExtentScrollController();

  // ── All initState, dispose, logic — completely unchanged ───────────────────

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = widget.initialDate!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToCurrentDate();
    });
  }

  void _jumpToCurrentDate() {
    final yearsSinceCurrent = _selectedDate.year - _currentDate.year;
    final dayIndex = _selectedDate.day - 1;
    _yearController.jumpToItem(yearsSinceCurrent);
    _dayController.jumpToItem(dayIndex);
    _monthController.jumpToPage(_selectedDate.month - _currentDate.month);
  }

  bool _isDateSelectable(DateTime date) {
    final DateTime dateOnly = DateTime(date.year, date.month, date.day);
    final DateTime currentDateOnly =
        DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    return !dateOnly.isBefore(currentDateOnly);
  }

  void _handleDateChanged() {
    if (_isDateSelectable(_selectedDate)) {
      widget.onDateChanged?.call(_selectedDate);
    }
  }

  List<Widget> _buildMonthPages() {
    return List.generate(12, (monthOffset) {
      final month = (_currentDate.month - 1 + monthOffset) % 12 + 1;
      final year =
          _currentDate.year + ((_currentDate.month - 1 + monthOffset) ~/ 12);
      return Center(
        child: Text(
          DateFormat('MMMM').format(DateTime(year, month)),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    });
  }

  // ── Build — container decoration + month header nav buttons added ──────────

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // ── Month header with nav chevrons ─────────────────────────────
          Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Previous month button
                GestureDetector(
                  onTap: () {
                    if (_monthController.page != null &&
                        _monthController.page! > 0) {
                      _monthController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Month PageView — logic unchanged
                Expanded(
                  child: PageView(
                    controller: _monthController,
                    onPageChanged: (monthOffset) {
                      final newMonth = (_currentDate.month + monthOffset) % 12;
                      final newYear = _currentDate.year +
                          ((_currentDate.month - 1 + monthOffset) ~/ 12);
                      setState(() {
                        _selectedDate = DateTime(
                          newYear,
                          newMonth,
                          _selectedDate.day.clamp(
                            newMonth + 1 == _currentDate.month &&
                                    newYear == _currentDate.year
                                ? _currentDate.day
                                : 1,
                            DateTime(newYear, newMonth + 2, 0).day,
                          ),
                        );
                      });
                      _handleDateChanged();
                    },
                    children: _buildMonthPages(),
                  ),
                ),
                // Next month button
                GestureDetector(
                  onTap: () {
                    if (_monthController.page != null &&
                        _monthController.page! < 11) {
                      _monthController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Day and year scroll wheels — logic completely unchanged ─────
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: ListWheelScrollView(
                    controller: _dayController,
                    itemExtent: 50,
                    perspective: 0.01,
                    diameterRatio: 1.5,
                    squeeze: 1.0,
                    useMagnifier: true,
                    magnification: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (day) {
                      final newDay = day + 1;
                      final isCurrentMonth =
                          _selectedDate.year == _currentDate.year &&
                              _selectedDate.month == _currentDate.month;
                      if (isCurrentMonth && newDay < _currentDate.day) return;
                      setState(() {
                        _selectedDate = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          newDay,
                        );
                      });
                      _handleDateChanged();
                    },
                    children: List.generate(
                      DateTime(_selectedDate.year, _selectedDate.month + 1, 0)
                          .day,
                      (day) {
                        final dayNumber = day + 1;
                        final isCurrentMonth =
                            _selectedDate.year == _currentDate.year &&
                                _selectedDate.month == _currentDate.month;
                        final isDisabled =
                            isCurrentMonth && dayNumber < _currentDate.day;
                        return Center(
                          child: Text(
                            dayNumber.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              color: isDisabled
                                  ? Colors.grey[400]
                                  : _selectedDate.day == dayNumber
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryFixed
                                      : Colors.grey,
                              fontWeight: _selectedDate.day == dayNumber
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  ",",
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onPrimaryFixed,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: ListWheelScrollView(
                    controller: _yearController,
                    itemExtent: 50,
                    perspective: 0.01,
                    diameterRatio: 1.5,
                    squeeze: 1.0,
                    useMagnifier: true,
                    magnification: 1.2,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (yearOffset) {
                      final newYear = _currentDate.year + yearOffset;
                      final isCurrentYear = newYear == _currentDate.year;
                      setState(() {
                        _selectedDate = DateTime(
                          newYear,
                          _selectedDate.month,
                          _selectedDate.day.clamp(
                            isCurrentYear &&
                                    _selectedDate.month == _currentDate.month
                                ? _currentDate.day
                                : 1,
                            DateTime(newYear, _selectedDate.month + 1, 0).day,
                          ),
                        );
                      });
                      _handleDateChanged();
                    },
                    children: List.generate(10, (yearOffset) {
                      final year = _currentDate.year + yearOffset;
                      return Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            color: _selectedDate.year == year
                                ? Theme.of(context).colorScheme.onPrimaryFixed
                                : Colors.grey,
                            fontWeight: _selectedDate.year == year
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
