import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/staff_controller.dart';
import '../models/shift.dart';

class StaffCalendarPage extends ConsumerWidget {
  const StaffCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(staffControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dienstplan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => ref.read(staffControllerProvider.notifier).setView(v),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: 'day', child: Text('Tag')),
              PopupMenuItem(value: 'week', child: Text('Woche')),
              PopupMenuItem(value: 'month', child: Text('Monat')),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openShiftForm(context, ref),
        label: const Text('Schicht'),
        icon: const Icon(Icons.add),
      ),
      body: s.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8),
              child: _buildCalendar(context, s.shifts, s.view),
            ),
    );
  }

  Widget _buildCalendar(BuildContext ctx, List<Shift> shifts, String view) {
    switch (view) {
      case 'day':
        return _DayView(shifts: shifts);
      case 'month':
        return _MonthView(shifts: shifts);
      case 'week':
      default:
        return _WeekView(shifts: shifts);
    }
  }

  void _openShiftForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _ShiftFormDialog(ref: ref),
    );
  }
}

class _WeekView extends StatelessWidget {
  final List<Shift> shifts;
  const _WeekView({required this.shifts});

  @override
  Widget build(BuildContext context) {
    // Simplified week grid: group by weekday
    final map = <int, List<Shift>>{};
    for (final sh in shifts) {
      final w = sh.startAt.weekday;
      (map[w] ??= []).add(sh);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (i) {
        final day = (i + 1);
        final dayShifts = map[day] ?? [];
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_weekdayName(day), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...dayShifts.map((s) => _ShiftCard(s)),
              const SizedBox(height: 16),
            ],
          ),
        );
      }),
    );
  }

  String _weekdayName(int d) => ['', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][d];
}

class _DayView extends StatelessWidget {
  final List<Shift> shifts;
  const _DayView({required this.shifts});

  @override
  Widget build(BuildContext context) {
    // Simple list ordered by start
    final sorted = [...shifts]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return ListView(children: sorted.map((s) => _ShiftCard(s)).toList());
  }
}

class _MonthView extends StatelessWidget {
  final List<Shift> shifts;
  const _MonthView({required this.shifts});

  @override
  Widget build(BuildContext context) {
    // Placeholder month view (grid 5x7) with counts
    final counts = List.generate(31, (_) => 0);
    for (final s in shifts) {
      final d = s.startAt.day;
      if (d >= 1 && d <= 31) counts[d - 1]++;
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2,
      ),
      itemCount: 31,
      itemBuilder: (ctx, i) {
        final n = counts[i];
        return Card(
          child: Center(
            child: Text(
              '${i + 1}\n$n Schichten',
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final Shift shift;
  const _ShiftCard(this.shift);

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, shift.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text('${_fmt(shift.startAt)}–${_fmt(shift.endAt)}'),
        subtitle: Text('Stylist #${shift.stylistId} • ${shift.status}'),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            // TODO: edit/move/resize handlers (open forms)
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
            PopupMenuItem(value: 'move', child: Text('Verschieben')),
            PopupMenuItem(value: 'resize', child: Text('Dauer ändern')),
            PopupMenuItem(value: 'delete', child: Text('Löschen')),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Color _statusColor(BuildContext ctx, String s) {
    final cs = Theme.of(ctx).colorScheme;
    return switch (s) {
      'planned' => cs.secondary,
      'confirmed' => cs.primary,
      'swapped' => cs.tertiary,
      'canceled' => cs.error,
      _ => cs.secondary,
    };
  }
}

class _ShiftFormDialog extends ConsumerWidget {
  final WidgetRef ref;
  const _ShiftFormDialog({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final stylistCtrl = TextEditingController();

    return AlertDialog(
      title: const Text('Schicht anlegen'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: stylistCtrl,
              decoration: const InputDecoration(labelText: 'Stylist ID'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || v.isEmpty) ? 'Pflicht' : null,
            ),
            TextFormField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: 'Start (ISO)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Pflicht' : null,
            ),
            TextFormField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: 'Ende (ISO)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Pflicht' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            // TODO: call StaffRepository.createShift(...)
            Navigator.pop(context);
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}