import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DateRangePicker extends StatefulWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final Function(DateTime from, DateTime to) onDateRangeSelected;

  const DateRangePicker({
    super.key,
    this.fromDate,
    this.toDate,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTime? _selectedFrom;
  DateTime? _selectedTo;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedFrom = widget.fromDate;
    _selectedTo = widget.toDate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TableCalendar<DateTime>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                if (_selectedFrom == null && _selectedTo == null) {
                  return false;
                }
                if (_selectedFrom != null && _selectedTo == null) {
                  return isSameDay(day, _selectedFrom);
                }
                if (_selectedFrom != null && _selectedTo != null) {
                  return isSameDay(day, _selectedFrom) || isSameDay(day, _selectedTo);
                }
                return false;
              },
              rangeSelectionMode: RangeSelectionMode.enforced,
              rangeStartDay: _selectedFrom,
              rangeEndDay: _selectedTo,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  
                  if (_selectedFrom == null) {
                    _selectedFrom = selectedDay;
                    _selectedTo = null;
                  } else if (_selectedTo == null) {
                    if (selectedDay.isBefore(_selectedFrom!)) {
                      _selectedTo = _selectedFrom;
                      _selectedFrom = selectedDay;
                    } else {
                      _selectedTo = selectedDay;
                    }
                  } else {
                    _selectedFrom = selectedDay;
                    _selectedTo = null;
                  }
                });
              },
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFrom = null;
                      _selectedTo = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: _selectedFrom != null && _selectedTo != null
                      ? () => widget.onDateRangeSelected(_selectedFrom!, _selectedTo!)
                      : null,
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}