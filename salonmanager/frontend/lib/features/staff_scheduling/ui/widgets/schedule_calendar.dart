import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleCalendar extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String view;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final Function(Map<String, dynamic>) onEventTap;

  const ScheduleCalendar({
    super.key,
    required this.events,
    required this.view,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case 'day':
        return _DayView(
          events: events,
          selectedDate: selectedDate,
          onEventTap: onEventTap,
        );
      case 'month':
        return _MonthView(
          events: events,
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          onEventTap: onEventTap,
        );
      case 'week':
      default:
        return _WeekView(
          events: events,
          selectedDate: selectedDate,
          onDateChanged: onDateChanged,
          onEventTap: onEventTap,
        );
    }
  }
}

class _DayView extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final DateTime selectedDate;
  final Function(Map<String, dynamic>) onEventTap;

  const _DayView({
    required this.events,
    required this.selectedDate,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayEvents = events.where((e) {
      final start = DateTime.parse(e['start_at']);
      return start.year == selectedDate.year &&
          start.month == selectedDate.month &&
          start.day == selectedDate.day;
    }).toList();

    dayEvents.sort((a, b) => DateTime.parse(a['start_at']).compareTo(DateTime.parse(b['start_at'])));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return _EventCard(
          event: event,
          onTap: () => onEventTap(event),
        );
      },
    );
  }
}

class _WeekView extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final Function(Map<String, dynamic>) onEventTap;

  const _WeekView({
    required this.events,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Week navigation
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onDateChanged(selectedDate.subtract(const Duration(days: 7))),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('dd.MM.yyyy').format(weekStart) +
                    ' - ' +
                    DateFormat('dd.MM.yyyy').format(weekDays.last),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                onPressed: () => onDateChanged(selectedDate.add(const Duration(days: 7))),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Week grid
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: weekDays.map((day) {
              final dayEvents = events.where((e) {
                final start = DateTime.parse(e['start_at']);
                return start.year == day.year &&
                    start.month == day.month &&
                    start.day == day.day;
              }).toList();

              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _weekdayName(day.weekday),
                        style: Theme.of(context).textTheme.titleSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dayEvents.length,
                        itemBuilder: (context, index) {
                          final event = dayEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: _EventCard(
                              event: event,
                              onTap: () => onEventTap(event),
                              compact: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _weekdayName(int d) => ['', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][d];
}

class _MonthView extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final Function(Map<String, dynamic>) onEventTap;

  const _MonthView({
    required this.events,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
    final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final firstWeekday = monthStart.weekday;
    final daysInMonth = monthEnd.day;

    // Create calendar grid
    final calendarDays = <DateTime>[];
    
    // Add days from previous month
    for (int i = firstWeekday - 1; i > 0; i--) {
      calendarDays.add(monthStart.subtract(Duration(days: i)));
    }
    
    // Add days from current month
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(selectedDate.year, selectedDate.month, i));
    }
    
    // Add days from next month to complete the grid
    final remainingDays = 42 - calendarDays.length; // 6 weeks * 7 days
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(DateTime(selectedDate.year, selectedDate.month + 1, i));
    }

    return Column(
      children: [
        // Month navigation
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onDateChanged(DateTime(selectedDate.year, selectedDate.month - 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => onDateChanged(DateTime(selectedDate.year, selectedDate.month + 1)),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        // Month grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
            ),
            itemCount: calendarDays.length,
            itemBuilder: (context, index) {
              final day = calendarDays[index];
              final isCurrentMonth = day.month == selectedDate.month;
              final dayEvents = events.where((e) {
                final start = DateTime.parse(e['start_at']);
                return start.year == day.year &&
                    start.month == day.month &&
                    start.day == day.day;
              }).toList();

              return GestureDetector(
                onTap: () => onDateChanged(day),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isCurrentMonth
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: day.day == selectedDate.day
                        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCurrentMonth
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (dayEvents.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${dayEvents.length}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onTap;
  final bool compact;

  const _EventCard({
    required this.event,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final kind = event['kind'];
    final start = DateTime.parse(event['start_at']);
    final end = DateTime.parse(event['end_at']);
    final title = event['title'] ?? (kind == 'shift' ? 'Schicht' : 'Abwesenheit');
    final status = event['status'];

    Color getEventColor() {
      if (kind == 'absence') {
        return switch (status) {
          'approved' => Colors.green,
          'rejected' => Colors.red,
          'pending' => Colors.orange,
          _ => Colors.grey,
        };
      } else {
        return Theme.of(context).colorScheme.primary;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: EdgeInsets.all(compact ? 4 : 8),
        decoration: BoxDecoration(
          color: getEventColor().withOpacity(0.1),
          border: Border.all(color: getEventColor()),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: getEventColor(),
              ),
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!compact) ...[
              const SizedBox(height: 2),
              Text(
                '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (event['role'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  event['role'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
