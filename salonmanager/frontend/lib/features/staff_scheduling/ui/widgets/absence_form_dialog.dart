import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsenceFormDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const AbsenceFormDialog({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<AbsenceFormDialog> createState() => _AbsenceFormDialogState();
}

class _AbsenceFormDialogState extends State<AbsenceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _type = 'vacation';
  bool _isAllDay = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _reasonController.text = widget.initialData!['reason'] ?? '';
      _noteController.text = widget.initialData!['note'] ?? '';
      _type = widget.initialData!['type'] ?? 'vacation';
      
      final start = DateTime.parse(widget.initialData!['start_at']);
      _startDate = start;
      _startTime = TimeOfDay.fromDateTime(start);
      
      final end = DateTime.parse(widget.initialData!['end_at']);
      _endDate = end;
      _endTime = TimeOfDay.fromDateTime(end);
      
      _isAllDay = _startTime!.hour == 0 && _startTime!.minute == 0 &&
                  _endTime!.hour == 23 && _endTime!.minute == 59;
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 1));
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData != null ? 'Abwesenheit bearbeiten' : 'Abwesenheit beantragen'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: 'Art der Abwesenheit',
                ),
                items: const [
                  DropdownMenuItem(value: 'vacation', child: Text('Urlaub')),
                  DropdownMenuItem(value: 'sick', child: Text('Krankheit')),
                  DropdownMenuItem(value: 'other', child: Text('Sonstiges')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Ganztägig'),
                subtitle: const Text('Von 00:00 bis 23:59'),
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value;
                    if (value) {
                      _startTime = const TimeOfDay(hour: 0, minute: 0);
                      _endTime = const TimeOfDay(hour: 23, minute: 59);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Von'),
                      subtitle: Text(_startDate != null && _startTime != null
                          ? '${DateFormat('dd.MM.yyyy').format(_startDate!)} ${_isAllDay ? '' : _startTime!.format(context)}'
                          : 'Datum wählen'),
                      onTap: _selectStartDateTime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListTile(
                      title: const Text('Bis'),
                      subtitle: Text(_endDate != null && _endTime != null
                          ? '${DateFormat('dd.MM.yyyy').format(_endDate!)} ${_isAllDay ? '' : _endTime!.format(context)}'
                          : 'Datum wählen'),
                      onTap: _selectEndDateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Grund',
                  hintText: 'Kurze Beschreibung der Abwesenheit',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Grund ist erforderlich';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notizen',
                  hintText: 'Zusätzliche Informationen (optional)',
                ),
                maxLines: 3,
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
          onPressed: _saveAbsence,
          child: Text(widget.initialData != null ? 'Aktualisieren' : 'Beantragen'),
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
      if (!_isAllDay) {
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
      } else {
        setState(() {
          _startDate = date;
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      if (!_isAllDay) {
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
      } else {
        setState(() {
          _endDate = date;
        });
      }
    }
  }

  void _saveAbsence() {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie Start- und Enddatum')),
      );
      return;
    }

    final startDateTime = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _isAllDay ? 0 : _startTime!.hour,
      _isAllDay ? 0 : _startTime!.minute,
    );
    
    final endDateTime = DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _isAllDay ? 23 : _endTime!.hour,
      _isAllDay ? 59 : _endTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enddatum muss nach Startdatum liegen')),
      );
      return;
    }

    final absenceData = {
      'user_id': 1, // TODO: Get from auth context
      'start_at': startDateTime.toIso8601String(),
      'end_at': endDateTime.toIso8601String(),
      'from_date': _startDate!.toIso8601String().split('T')[0],
      'to_date': _endDate!.toIso8601String().split('T')[0],
      'type': _type,
      'reason': _reasonController.text,
      'note': _noteController.text.isEmpty ? null : _noteController.text,
    };

    widget.onSave(absenceData);
    Navigator.pop(context);
  }
}
