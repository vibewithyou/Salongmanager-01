import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Primary button - main CTA style
class SMPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool fullWidth;
  final Size? minimumSize;
  
  const SMPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.fullWidth = false,
    this.minimumSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: minimumSize,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
    
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary button - outlined style
class SMSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool fullWidth;
  final Size? minimumSize;
  
  const SMSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.fullWidth = false,
    this.minimumSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: minimumSize,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
    
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Ghost button - minimal style, no background
class SMGhostButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool fullWidth;
  final Size? minimumSize;
  
  const SMGhostButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.fullWidth = false,
    this.minimumSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final button = TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: cs.onSurface,
        minimumSize: minimumSize ?? const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.onSurface,
              ),
            )
          : child,
    );
    
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Icon button with consistent styling
class SMIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final double? iconSize;
  final Color? color;
  final bool filled;
  
  const SMIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.iconSize,
    this.color,
    this.filled = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    final iconButton = filled
        ? IconButton.filled(
            onPressed: onPressed,
            icon: Icon(icon, size: iconSize),
            color: color,
            tooltip: tooltip,
          )
        : IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: iconSize),
            color: color ?? cs.onSurfaceVariant,
            tooltip: tooltip,
          );
    
    return tooltip != null
        ? Tooltip(
            message: tooltip!,
            child: iconButton,
          )
        : iconButton;
  }
}

/// Floating action button
class SMFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String? tooltip;
  final bool extended;
  final bool small;
  
  const SMFloatingButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.extended = false,
    this.small = false,
  });
  
  @override
  Widget build(BuildContext context) {
    Widget fab;
    
    if (extended && child is Row) {
      fab = FloatingActionButton.extended(
        onPressed: onPressed,
        label: child,
        tooltip: tooltip,
      );
    } else if (small) {
      fab = FloatingActionButton.small(
        onPressed: onPressed,
        tooltip: tooltip,
        child: child,
      );
    } else {
      fab = FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        child: child,
      );
    }
    
    return fab;
  }
}

/// Button group for related actions
class SMButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment alignment;
  final double spacing;
  final bool vertical;
  
  const SMButtonGroup({
    super.key,
    required this.children,
    this.alignment = MainAxisAlignment.start,
    this.spacing = SMTokens.s2,
    this.vertical = false,
  });
  
  @override
  Widget build(BuildContext context) {
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (alignment == MainAxisAlignment.spaceEvenly ||
              alignment == MainAxisAlignment.spaceBetween)
            Expanded(child: children[i])
          else
            children[i],
          if (i < children.length - 1 &&
              alignment != MainAxisAlignment.spaceEvenly &&
              alignment != MainAxisAlignment.spaceBetween)
            SizedBox(width: spacing),
        ],
      ],
    );
  }
}