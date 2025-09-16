import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/schedule_controller.dart';
import '../../../common/ui/sm_card.dart';
import '../../../common/ui/empty_state.dart';
import 'widgets/shift_form_dialog.dart';
import 'widgets/absence_form_dialog.dart';
import 'widgets/schedule_calendar.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 7));
  DateTime _to = DateTime.now().add(const Duration(days: 21));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scheduleControllerProvider.notifier).loadRange(_from, _to);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduleControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dienstpläne'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (view) {
              ref.read(scheduleControllerProvider.notifier).setView(view);
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'day', child: Text('Tag')),
              PopupMenuItem(value: 'week', child: Text('Woche')),
              PopupMenuItem(value: 'month', child: Text('Monat')),
            ],
          ),
          IconButton(
            onPressed: () => _showWorkRulesDialog(context),
            icon: const Icon(Icons.settings),
            tooltip: 'Arbeitsregeln',
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Fehler: ${state.error}'),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(scheduleControllerProvider.notifier).loadRange(_from, _to);
                        },
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                )
              : state.events.isEmpty
                  ? const EmptyState(title: 'Noch keine Einträge')
                  : ScheduleCalendar(
                      events: state.events,
                      view: state.view,
                      selectedDate: state.selectedDate,
                      onDateChanged: (date) {
                        ref.read(scheduleControllerProvider.notifier).setSelectedDate(date);
                        _from = date.subtract(const Duration(days: 7));
                        _to = date.add(const Duration(days: 21));
                        ref.read(scheduleControllerProvider.notifier).loadRange(_from, _to);
                      },
                      onEventTap: (event) => _showEventDetails(context, event),
                    ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'absence',
            onPressed: () => _showAbsenceForm(context),
            child: const Icon(Icons.beach_access),
            tooltip: 'Abwesenheit beantragen',
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'shift',
            onPressed: () => _showShiftForm(context),
            child: const Icon(Icons.add),
            tooltip: 'Schicht erstellen',
          ),
        ],
      ),
    );
  }

  void _showShiftForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ShiftFormDialog(
        onSave: (shiftData) {
          ref.read(scheduleControllerProvider.notifier).createShift(shiftData);
        },
      ),
    );
  }

  void _showAbsenceForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AbsenceFormDialog(
        onSave: (absenceData) {
          ref.read(scheduleControllerProvider.notifier).requestAbsence(absenceData);
        },
      ),
    );
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(event['title'] ?? 'Ereignis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Typ: ${event['kind']}'),
            Text('Start: ${event['start_at']}'),
            Text('Ende: ${event['end_at']}'),
            if (event['role'] != null) Text('Rolle: ${event['role']}'),
            if (event['status'] != null) Text('Status: ${event['status']}'),
            if (event['reason'] != null) Text('Grund: ${event['reason']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
          if (event['kind'] == 'absence' && event['status'] == 'pending')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAbsenceDecisionDialog(context, event);
              },
              child: const Text('Entscheiden'),
            ),
        ],
      ),
    );
  }

  void _showAbsenceDecisionDialog(BuildContext context, Map<String, dynamic> absence) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Abwesenheit entscheiden'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${absence['type']} - ${absence['start_at']} bis ${absence['end_at']}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.read(scheduleControllerProvider.notifier).decideAbsence(
                          absence['id'],
                          'approve',
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Genehmigen'),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.read(scheduleControllerProvider.notifier).decideAbsence(
                          absence['id'],
                          'reject',
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Ablehnen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Arbeitsregeln'),
        content: const Text('Arbeitsregeln-Verwaltung wird implementiert...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}
