import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ScrollingTimePicker extends StatefulWidget {
  const ScrollingTimePicker(
      {super.key, required this.onTimeSelected, this.initialTime});
  final Function onTimeSelected;
  final TimeOfDay? initialTime;

  @override
  State<ScrollingTimePicker> createState() => _ScrollingTimePickerState();
}

class _ScrollingTimePickerState extends State<ScrollingTimePicker> {
  final FixedExtentScrollController _hourController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteController =
      FixedExtentScrollController();
  final FixedExtentScrollController _periodController =
      FixedExtentScrollController();

  int _selectedHour = TimeOfDay.now().hourOfPeriod;
  int _selectedMinute = TimeOfDay.now().minute;
  int _selectedPeriod = TimeOfDay.now().period == DayPeriod.am ? 0 : 1;
  bool _initialized = false;

  // ── All initState, dispose, listeners — completely unchanged ───────────────

  @override
  void initState() {
    super.initState();
    if (widget.initialTime != null) {
      _selectedHour = widget.initialTime!.hourOfPeriod;
      _selectedMinute = widget.initialTime!.minute;
      _selectedPeriod = widget.initialTime!.period == DayPeriod.am ? 0 : 1;
    }
    _hourController.addListener(_onHourChanged);
    _minuteController.addListener(_onMinuteChanged);
    _periodController.addListener(_onPeriodChanged);
  }

  @override
  void dispose() {
    _hourController.removeListener(_onHourChanged);
    _minuteController.removeListener(_onMinuteChanged);
    _periodController.removeListener(_onPeriodChanged);
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  void _onHourChanged() {
    setState(() {
      _selectedHour = (_hourController.selectedItem % 12) + 1;
      widget.onTimeSelected(currentTime);
    });
  }

  void _onMinuteChanged() {
    setState(() {
      _selectedMinute = _minuteController.selectedItem % 60;
      widget.onTimeSelected(currentTime);
    });
  }

  void _onPeriodChanged() {
    setState(() {
      _selectedPeriod = _periodController.selectedItem % 2;
      widget.onTimeSelected(currentTime);
    });
  }

  TimeOfDay get currentTime {
    return TimeOfDay(
      hour: _selectedPeriod == 0 ? _selectedHour : _selectedHour + 12,
      minute: _selectedMinute,
    );
  }

  List<String> get _periodLabels {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ar') return ['ص', 'م'];
    if (locale.languageCode == 'fa') return ['ق.ظ', 'ب.ظ'];
    if (locale.languageCode == 'ur') return ['ص', 'ش'];
    return ['AM', 'PM'];
  }

  bool get _isRTL {
    final locale = Localizations.localeOf(context);
    return intl.Bidi.isRtlLanguage(locale.toString());
  }

  // ── Build — only container decoration changed ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hourController.jumpToItem(_selectedHour - 1);
        _minuteController.jumpToItem(_selectedMinute);
        _periodController.jumpToItem(_selectedPeriod);
      });
      _initialized = true;
    }

    return Center(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Directionality(
          textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildTimePickerColumns(),
          ),
        ),
      ),
    );
  }

  // ── Column contents — completely unchanged ─────────────────────────────────

  List<Widget> _buildTimePickerColumns() {
    final periodLabels = _periodLabels;
    final widgets = <Widget>[
      SizedBox(
        width: 80,
        child: ListWheelScrollView(
          controller: _hourController,
          itemExtent: 50,
          perspective: 0.01,
          diameterRatio: 1.5,
          squeeze: 1.0,
          useMagnifier: true,
          magnification: 1.2,
          physics: const FixedExtentScrollPhysics(),
          children: List.generate(12, (index) {
            final hour = index + 1;
            return Center(
              child: Text(
                hour.toString(),
                style: TextStyle(
                  fontSize: 24,
                  color: _selectedHour == hour
                      ? Theme.of(context).colorScheme.onPrimaryFixed
                      : Colors.grey,
                  fontWeight: _selectedHour == hour
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ),
      Text(
        ":",
        style: TextStyle(
          fontSize: 24,
          color: Theme.of(context).colorScheme.onPrimaryFixed,
        ),
      ),
      SizedBox(
        width: 80,
        child: ListWheelScrollView(
          controller: _minuteController,
          itemExtent: 50,
          perspective: 0.01,
          diameterRatio: 1.5,
          squeeze: 1.0,
          useMagnifier: true,
          magnification: 1.2,
          physics: const FixedExtentScrollPhysics(),
          children: List.generate(60, (index) {
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 24,
                  color: _selectedMinute == index
                      ? Theme.of(context).colorScheme.onPrimaryFixed
                      : Colors.grey,
                  fontWeight: _selectedMinute == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ),
      SizedBox(
        width: 80,
        child: ListWheelScrollView(
          controller: _periodController,
          itemExtent: 50,
          perspective: 0.01,
          diameterRatio: 1.5,
          squeeze: 1.0,
          useMagnifier: true,
          magnification: 1.2,
          physics: const FixedExtentScrollPhysics(),
          children: periodLabels.map((period) {
            final index = periodLabels.indexOf(period);
            return Center(
              child: Text(
                period,
                style: TextStyle(
                  fontSize: _isRTL ? 20 : 18,
                  color: _selectedPeriod == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  fontWeight: _selectedPeriod == index
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ];

    return _isRTL ? widgets.reversed.toList() : widgets;
  }
}
