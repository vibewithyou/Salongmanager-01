import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const ShiftFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ShiftFormDialog> createState() => _ShiftFormDialogState();
}

class _ShiftFormDialogState extends State<ShiftFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _rruleController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isRecurring = false;
  bool _published = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _roleController.text = widget.initialData!['role'] ?? '';
      _rruleController.text = widget.initialData!['rrule'] ?? '';
      _published = widget.initialData!['published'] ?? true;
      
      final start = DateTime.parse(widget.initialData!['start_at']);
      _startDate = start;
      _startTime = TimeOfDay.fromDateTime(start);
      
      final end = DateTime.parse(widget.initialData!['end_at']);
      _endDate = end;
      _endTime = TimeOfDay.fromDateTime(end);
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(hours: 8));
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 17, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roleController.dispose();
    _rruleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData != null ? 'Schicht bearbeiten' : 'Neue Schicht'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                  hintText: 'z.B. Frühschicht, Spätschicht',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Titel ist erforderlich';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Rolle',
                  hintText: 'z.B. Stylist, Rezeptionist',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start'),
                      subtitle: Text(_startDate != null && _startTime != null
                          ? '${DateFormat('dd.MM.yyyy').format(_startDate!)} ${_startTime!.format(context)}'
                          : 'Datum und Zeit wählen'),
                      onTap: _selectStartDateTime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: const Text('Ende'),
                      subtitle: Text(_endDate != null && _endTime != null
                          ? '${DateFormat('dd.MM.yyyy').format(_endDate!)} ${_endTime!.format(context)}'
                          : 'Datum und Zeit wählen'),
                      onTap: _selectEndDateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Wiederkehrend'),
                subtitle: const Text('Schicht regelmäßig wiederholen'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rruleController,
                  decoration: const InputDecoration(
                    labelText: 'Wiederholungsregel',
                    hintText: 'FREQ=WEEKLY;BYDAY=MO,TU;UNTIL=2025-12-31',
                    helperText: 'RFC5545-Format (z.B. wöchentlich Mo,Di)',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Veröffentlicht'),
                subtitle: const Text('Schicht ist sichtbar'),
                value: _published,
                onChanged: (value) {
                  setState(() {
                    _published = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _saveShift,
          child: Text(widget.initialData != null ? 'Aktualisieren' : 'Erstellen'),
        ),
      ],
    );
  }

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
      );
      
      if (time != null) {
        setState(() {
          _startDate = date;
          _startTime = time;
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _endTime ?? const TimeOfDay(hour: 17, minute: 0),
      );
      
      if (time != null) {
        setState(() {
          _endDate = date;
          _endTime = time;
        });
      }
    }
  }

  void _saveShift() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie Start- und Endzeit')),
      );
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endzeit muss nach Startzeit liegen')),
      );
      return;
    }

    final shiftData = {
      'user_id': 1, // TODO: Get from auth context
      'title': _titleController.text,
      'role': _roleController.text.isEmpty ? null : _roleController.text,
      'start_at': startDateTime.toIso8601String(),
      'end_at': endDateTime.toIso8601String(),
      'rrule': _isRecurring && _rruleController.text.isNotEmpty ? _rruleController.text : null,
      'published': _published,
    };

    widget.onSave(shiftData);
    Navigator.pop(context);
  }
}
