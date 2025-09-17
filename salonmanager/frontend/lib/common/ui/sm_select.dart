import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Select dropdown with consistent styling
class SMSelect<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<SMSelectOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(T?)? validator;
  final Widget? Function(T)? itemBuilder;
  final String? Function(T)? displayText;
  final bool searchable;
  final String? searchHint;

  const SMSelect({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.value,
    required this.options,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.itemBuilder,
    this.displayText,
    this.searchable = false,
    this.searchHint,
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
        DropdownButtonFormField<T>(
          value: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: SMTokens.s4,
              vertical: SMTokens.s3,
            ),
            filled: true,
            fillColor: cs.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: SMTokens.rMd,
              borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
            ),
          ),
          items: options.map((option) {
            return DropdownMenuItem<T>(
              value: option.value,
              enabled: option.enabled,
              child: itemBuilder?.call(option.value) ??
                  Text(
                    displayText?.call(option.value) ?? option.label,
                    style: TextStyle(
                      color: option.enabled
                          ? cs.onSurface
                          : cs.onSurface.withOpacity(0.5),
                    ),
                  ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Select option data class
class SMSelectOption<T> {
  final T value;
  final String label;
  final bool enabled;
  final Widget? icon;

  const SMSelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.icon,
  });
}

/// Multi-select dropdown
class SMMultiSelect<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final List<T> selectedValues;
  final List<SMSelectOption<T>> options;
  final ValueChanged<List<T>>? onChanged;
  final bool enabled;
  final bool required;
  final String? Function(List<T>?)? validator;
  final Widget? Function(T)? itemBuilder;
  final String? Function(T)? displayText;
  final int? maxSelections;
  final String? maxSelectionsText;

  const SMMultiSelect({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    required this.selectedValues,
    required this.options,
    this.onChanged,
    this.enabled = true,
    this.required = false,
    this.validator,
    this.itemBuilder,
    this.displayText,
    this.maxSelections,
    this.maxSelectionsText,
  });

  @override
  State<SMMultiSelect<T>> createState() => _SMMultiSelectState<T>();
}

class _SMMultiSelectState<T> extends State<SMMultiSelect<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.selectedValues);
  }

  @override
  void didUpdateWidget(SMMultiSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = List.from(widget.selectedValues);
    }
  }

  void _toggleSelection(T value) {
    if (!widget.enabled) return;

    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        if (widget.maxSelections != null &&
            _selectedValues.length >= widget.maxSelections!) {
          return;
        }
        _selectedValues.add(value);
      }
    });

    widget.onChanged?.call(_selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: hasError ? cs.error : cs.onSurface,
              ),
              children: widget.required
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
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? cs.error : cs.outline,
              width: hasError ? 2 : 1,
            ),
            borderRadius: SMTokens.rMd,
            color: widget.enabled
                ? cs.surfaceVariant.withOpacity(0.3)
                : cs.surfaceVariant.withOpacity(0.1),
          ),
          child: Column(
            children: [
              if (widget.hint != null)
                Padding(
                  padding: const EdgeInsets.all(SMTokens.s4),
                  child: Text(
                    widget.hint!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              if (_selectedValues.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SMTokens.s4),
                  child: Wrap(
                    spacing: SMTokens.s2,
                    runSpacing: SMTokens.s2,
                    children: _selectedValues.map((value) {
                      final option = widget.options
                          .firstWhere((opt) => opt.value == value);
                      return Chip(
                        label: Text(
                          widget.displayText?.call(value) ?? option.label,
                        ),
                        onDeleted: widget.enabled
                            ? () => _toggleSelection(value)
                            : null,
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                ),
              if (widget.maxSelections != null &&
                  _selectedValues.length >= widget.maxSelections!)
                Padding(
                  padding: const EdgeInsets.all(SMTokens.s4),
                  child: Text(
                    widget.maxSelectionsText ??
                        'Maximal ${widget.maxSelections} Auswahl(en)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.error,
                    ),
                  ),
                ),
              const Divider(height: 1),
              ...widget.options.map((option) {
                final isSelected = _selectedValues.contains(option.value);
                final canSelect = widget.enabled &&
                    option.enabled &&
                    (isSelected ||
                        widget.maxSelections == null ||
                        _selectedValues.length < widget.maxSelections!);

                return ListTile(
                  enabled: canSelect,
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: canSelect
                        ? (_) => _toggleSelection(option.value)
                        : null,
                  ),
                  title: widget.itemBuilder?.call(option.value) ??
                      Text(
                        widget.displayText?.call(option.value) ?? option.label,
                        style: TextStyle(
                          color: canSelect
                              ? cs.onSurface
                              : cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                  onTap: canSelect
                      ? () => _toggleSelection(option.value)
                      : null,
                );
              }),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
        if (widget.errorText != null) ...[
          const SizedBox(height: SMTokens.s2),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.error,
            ),
          ),
        ],
      ],
    );
  }
}
