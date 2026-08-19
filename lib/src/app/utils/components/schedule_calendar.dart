import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:business_manager_web_ui/src/app/theme/responsive_utils.dart';
import '../../../models/order_model.dart';

class ScheduleCalendar extends StatefulWidget {
  final List<Orders>? orders;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? initialDate;
  final Color dotColor;

  const ScheduleCalendar({
    super.key,
    this.onDateSelected,
    this.initialDate,
    this.dotColor = Colors.blue,
    this.orders,
  });

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  Map<DateTime, int> appointments = {};
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  ResponsiveUtils? responsive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    responsive = ResponsiveUtils(context);
  }

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.initialDate ?? DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime.now();
    if (widget.orders!.isNotEmpty) {
      assignOrdersToCalendar();
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive!.scaleHeight(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdays() {
    final weekdays = DateFormat.E().dateSymbols.SHORTWEEKDAYS;
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day.substring(0, 1),
              style: TextStyle(
                fontSize: responsive!.scaleFont(12),
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarDays() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday;

    // Group appointments by date for easy lookup
    final appointmentsByDate = groupBy(
      appointments.entries.toList(),
      (entry) => DateTime(entry.key.year, entry.key.month, entry.key.day),
    );

    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.2, // Makes items taller than wide
          mainAxisSpacing: 0, // No vertical space between rows
          crossAxisSpacing: 0, // No horizontal space between items
        ),
        itemCount: startingWeekday - 1 + daysInMonth,
        itemBuilder: (context, index) {
          final dayIndex = index - (startingWeekday - 1);
          if (dayIndex < 0) return Container(); // Empty space before 1st

          final day = dayIndex + 1;
          final date = DateTime(_currentMonth.year, _currentMonth.month, day);
          final isSelected = _selectedDate.year == date.year &&
              _selectedDate.month == date.month &&
              _selectedDate.day == date.day;
          final isToday = date.year == DateTime.now().year &&
              date.month == DateTime.now().month &&
              date.day == DateTime.now().day;
          final appointmentCount =
              appointmentsByDate[date]?.firstOrNull?.value ?? 0;
          return GestureDetector(
            onTap: () => _selectDate(date),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? widget.dotColor.withValues(alpha: 0.2) : null,
                border: isToday
                    ? Border.all(color: widget.dotColor, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString(),
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isToday && !isSelected
                          ? widget.dotColor
                          : isSelected
                              ? widget.dotColor
                              : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (appointmentCount > 0)
                    _buildAppointmentDots(appointmentCount, appointments),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentDots(int count, Map<DateTime, int> appointments) {
    const maxDots = 3;
    final dotCount = count > maxDots ? maxDots : count;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(dotCount, (index) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.dotColor,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: responsive!.screenHeight * 0.5, // Constrain maximum height
        minHeight: responsive!.scaleHeight(280), // Minimum height
      ),
      child: Padding(
        padding: responsive!.responsivePaddingM,
        // On a wide desktop window the grid would otherwise stretch to fill
        // the whole content pane; since each row's height is tied to cell
        // width via a fixed childAspectRatio, that makes rows taller than
        // the maxHeight above can fit, silently clipping the bottom of the
        // month. Capping the width (matching the app's existing 480 mobile-
        // width convention) keeps cells — and therefore row height — from
        // growing past what fits, and just centers the calendar instead.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildWeekdays(),
                  SizedBox(height: responsive!.scaleWidth(2)),
                  _buildCalendarDays(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void assignOrdersToCalendar() {
    for (var order in widget.orders!) {
      if (order.scheduledDate != null && order.scheduledAt != null) {
        var date = DateTime(
          order.scheduledDate!.year,
          order.scheduledDate!.month,
          order.scheduledDate!.day,
        );
        if (appointments.containsKey(date)) {
          appointments[date] = appointments[date]! + 1; // Increment if exists
        } else {
          appointments[date] = 1; // Initialize if new
        }
      }
    }
  }
}
