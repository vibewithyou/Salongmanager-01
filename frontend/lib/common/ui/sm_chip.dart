import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Custom chip widget with consistent styling
class SMChip extends StatelessWidget {
  final String label;
  final Widget? avatar;
  final Widget? deleteIcon;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? deleteIconColor;
  final EdgeInsetsGeometry? padding;
  final bool outlined;
  
  const SMChip({
    super.key,
    required this.label,
    this.avatar,
    this.deleteIcon,
    this.onDeleted,
    this.onPressed,
    this.selected = false,
    this.backgroundColor,
    this.selectedColor,
    this.deleteIconColor,
    this.padding,
    this.outlined = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final chip = Chip(
      label: Text(label),
      avatar: avatar,
      deleteIcon: deleteIcon,
      onDeleted: onDeleted,
      backgroundColor: outlined
          ? Colors.transparent
          : selected
              ? selectedColor ?? cs.primary.withOpacity(0.15)
              : backgroundColor,
      side: outlined
          ? BorderSide(
              color: selected ? cs.primary : cs.outline,
              width: selected ? 2 : 1,
            )
          : null,
      deleteIconColor: deleteIconColor,
      padding: padding,
      labelStyle: TextStyle(
        color: selected ? cs.primary : null,
        fontWeight: selected ? FontWeight.w600 : null,
      ),
    );
    
    if (onPressed != null) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: chip,
      );
    }
    
    return chip;
  }
}

/// Choice chip for selections
class SMChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;
  final bool outlined;
  final Color? selectedColor;
  final Color? backgroundColor;
  
  const SMChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.avatar,
    this.outlined = false,
    this.selectedColor,
    this.backgroundColor,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      backgroundColor: outlined ? Colors.transparent : backgroundColor,
      selectedColor: selectedColor ?? cs.primary.withOpacity(0.15),
      side: outlined
          ? BorderSide(
              color: selected ? cs.primary : cs.outline,
              width: selected ? 2 : 1,
            )
          : null,
      labelStyle: TextStyle(
        color: selected ? cs.primary : null,
        fontWeight: selected ? FontWeight.w600 : null,
      ),
    );
  }
}

/// Filter chip for filtering
class SMFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;
  final bool showCheckmark;
  
  const SMFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.avatar,
    this.showCheckmark = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
      showCheckmark: showCheckmark,
    );
  }
}

/// Input chip for form inputs
class SMInputChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final VoidCallback? onPressed;
  final Widget? avatar;
  final bool enabled;
  
  const SMInputChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.onPressed,
    this.avatar,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: enabled ? onDeleted : null,
      onPressed: enabled ? onPressed : null,
      avatar: avatar,
      isEnabled: enabled,
    );
  }
}

/// Chip group for organizing chips
class SMChipGroup extends StatelessWidget {
  final List<Widget> chips;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAlignment;
  
  const SMChipGroup({
    super.key,
    required this.chips,
    this.spacing = SMTokens.s2,
    this.runSpacing = SMTokens.s2,
    this.alignment = WrapAlignment.start,
    this.crossAlignment = WrapCrossAlignment.start,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      crossAxisAlignment: crossAlignment,
      children: chips,
    );
  }
}