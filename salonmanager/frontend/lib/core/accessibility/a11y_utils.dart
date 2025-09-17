import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// Accessibility utilities and helpers
class A11yUtils {
  /// Check if a color combination meets WCAG AA contrast requirements
  static bool meetsContrastRatio({
    required Color foreground,
    required Color background,
    bool isLargeText = false,
  }) {
    final ratio = _calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }
  
  /// Calculate contrast ratio between two colors
  static double _calculateContrastRatio(Color foreground, Color background) {
    final l1 = foreground.computeLuminance();
    final l2 = background.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Get a contrasting color (black or white) for the given background
  static Color getContrastingColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
  
  /// Wrap widget with Semantics for screen readers
  static Widget semanticLabel({
    required Widget child,
    required String label,
    String? hint,
    bool? button,
    bool? enabled,
    bool? focusable,
    bool? focused,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: button,
      enabled: enabled,
      focusable: focusable,
      focused: focused,
      child: child,
    );
  }
  
  /// Announce message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.of(context));
  }
  
  /// Create accessible touch target
  static Widget touchTarget({
    required Widget child,
    double minSize = SMTokens.touchTargetMin,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
  
  /// Create focus indicator wrapper
  static Widget focusIndicator({
    required Widget child,
    required bool hasFocus,
    Color? focusColor,
    double width = 2.0,
  }) {
    return Container(
      decoration: hasFocus
          ? BoxDecoration(
              border: Border.all(
                color: focusColor ?? Colors.blue,
                width: width,
              ),
              borderRadius: SMTokens.rMd,
            )
          : null,
      child: child,
    );
  }
  
  /// Check text scale factor
  static bool isLargeTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }
  
  /// Get adapted spacing based on text scale
  static double adaptSpacing(BuildContext context, double baseSpacing) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    if (scaleFactor > 1.3) {
      return baseSpacing * 1.2;
    }
    return baseSpacing;
  }
}

/// Accessible tooltip widget
class A11yTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final bool preferBelow;
  
  const A11yTooltip({
    super.key,
    required this.child,
    required this.message,
    this.preferBelow = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message,
      child: Tooltip(
        message: message,
        preferBelow: preferBelow,
        child: child,
      ),
    );
  }
}

/// Skip to content button for keyboard navigation
class SkipToContent extends StatelessWidget {
  final VoidCallback onSkip;
  final String label;
  
  const SkipToContent({
    super.key,
    required this.onSkip,
    this.label = 'Zum Hauptinhalt springen',
  });
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: 0,
      child: TextButton(
        onPressed: onSkip,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: Text(label),
      ),
    );
  }
}

/// High contrast mode detector
class HighContrastDetector extends StatelessWidget {
  final Widget child;
  final Widget? highContrastChild;
  
  const HighContrastDetector({
    super.key,
    required this.child,
    this.highContrastChild,
  });
  
  @override
  Widget build(BuildContext context) {
    final highContrast = MediaQuery.of(context).highContrast;
    
    if (highContrast && highContrastChild != null) {
      return highContrastChild!;
    }
    
    return child;
  }
}

/// Reduced motion detector
class ReducedMotionDetector extends StatelessWidget {
  final Widget child;
  final Widget? reducedMotionChild;
  
  const ReducedMotionDetector({
    super.key,
    required this.child,
    this.reducedMotionChild,
  });
  
  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.of(context).disableAnimations;
    
    if (reducedMotion && reducedMotionChild != null) {
      return reducedMotionChild!;
    }
    
    return child;
  }
}