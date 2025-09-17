import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/tokens.dart';

/// Date picker field with consistent styling
class SMDateField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool required;
  final String? Function(DateTime?)? validator;
  final DateFormat? format;
  final String? Function(DateTime)? formatter;

  const SMDateField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.format,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError ? cs.error : cs.onSurface,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: cs.error),
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: SMTokens.s2),
        ],
        InkWell(
          onTap: enabled ? () => _selectDate(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SMTokens.s4,
              vertical: SMTokens.s3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? cs.error : cs.outline,
                width: hasError ? 2 : 1,
              ),
              borderRadius: SMTokens.rMd,
              color: enabled
                  ? cs.surfaceVariant.withOpacity(0.3)
                  : cs.surfaceVariant.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: SMTokens.s3),
                Expanded(
                  child: Text(
                    value != null
                        ? (formatter?.call(value!) ??
                            (format ?? DateFormat('dd.MM.yyyy')).format(value!))
                        : hint ?? 'Datum auswählen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: cs.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != value) {
      onChanged?.call(picked);
    }
  }
}

/// Time picker field with consistent styling
class SMTimeField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(TimeOfDay?)? validator;
  final String? Function(TimeOfDay)? formatter;

  const SMTimeField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError ? cs.error : cs.onSurface,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: cs.error),
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: SMTokens.s2),
        ],
        InkWell(
          onTap: enabled ? () => _selectTime(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SMTokens.s4,
              vertical: SMTokens.s3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? cs.error : cs.outline,
                width: hasError ? 2 : 1,
              ),
              borderRadius: SMTokens.rMd,
              color: enabled
                  ? cs.surfaceVariant.withOpacity(0.3)
                  : cs.surfaceVariant.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: SMTokens.s3),
                Expanded(
                  child: Text(
                    value != null
                        ? (formatter?.call(value!) ?? value!.format(context))
                        : hint ?? 'Uhrzeit auswählen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: cs.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != value) {
      onChanged?.call(picked);
    }
  }
}

/// Date and time picker field
class SMDateTimeField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool required;
  final String? Function(DateTime?)? validator;
  final DateFormat? format;
  final String? Function(DateTime)? formatter;

  const SMDateTimeField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.format,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError ? cs.error : cs.onSurface,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: cs.error),
                      )
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: SMTokens.s2),
        ],
        InkWell(
          onTap: enabled ? () => _selectDateTime(context) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SMTokens.s4,
              vertical: SMTokens.s3,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? cs.error : cs.outline,
                width: hasError ? 2 : 1,
              ),
              borderRadius: SMTokens.rMd,
              color: enabled
                  ? cs.surfaceVariant.withOpacity(0.3)
                  : cs.surfaceVariant.withOpacity(0.1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event,
                  size: 20,
                  color: enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(width: SMTokens.s3),
                Expanded(
                  child: Text(
                    value != null
                        ? (formatter?.call(value!) ??
                            (format ?? DateFormat('dd.MM.yyyy HH:mm')).format(value!))
                        : hint ?? 'Datum und Uhrzeit auswählen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.arrow_drop_down,
                    color: cs.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    // First select date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: cs.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Then select time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: value != null
            ? TimeOfDay.fromDateTime(value!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: cs.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (combined != value) {
          onChanged?.call(combined);
        }
      }
    }
  }
}
