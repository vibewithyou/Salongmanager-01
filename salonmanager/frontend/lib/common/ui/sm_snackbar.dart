import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Snackbar helper for consistent snackbar styling
class SMSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    bool showCloseIcon = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final (bgColor, fgColor, icon) = switch (type) {
      SnackbarType.info => (cs.inverseSurface, cs.onInverseSurface, Icons.info_outline),
      SnackbarType.success => (SMTokens.success, SMTokens.white, Icons.check_circle_outline),
      SnackbarType.warning => (SMTokens.warning, SMTokens.black, Icons.warning_amber_rounded),
      SnackbarType.error => (cs.error, cs.onError, Icons.error_outline),
    };
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: fgColor, size: 20),
            const SizedBox(width: SMTokens.s3),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: fgColor),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: duration,
        action: action,
        showCloseIcon: showCloseIcon,
        closeIconColor: fgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        margin: const EdgeInsets.all(SMTokens.s4),
      ),
    );
  }
  
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    bool showCloseIcon = false,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      action: action,
      showCloseIcon: showCloseIcon,
    );
  }
  
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    bool showCloseIcon = false,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      action: action,
      showCloseIcon: showCloseIcon,
    );
  }
  
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 5),
    SnackBarAction? action,
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      action: action,
      showCloseIcon: showCloseIcon,
    );
  }
  
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
    SnackBarAction? action,
    bool showCloseIcon = true,
  }) {
    show(
      context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      action: action,
      showCloseIcon: showCloseIcon,
    );
  }
  
  static void showLoading(
    BuildContext context, {
    String message = 'Wird geladen...',
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: SMTokens.s3),
            Text(message),
          ],
        ),
        duration: const Duration(days: 365), // Long duration
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        margin: const EdgeInsets.all(SMTokens.s4),
      ),
    );
  }
  
  static void hideLoading(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
  
  static void hideAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

enum SnackbarType {
  info,
  success,
  warning,
  error,
}

/// Toast-style snackbar (minimal, auto-dismiss)
class SMToast {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        position: position,
        theme: theme,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastPosition position;
  final ThemeData theme;
  final VoidCallback onDismiss;
  
  const _ToastWidget({
    required this.message,
    required this.position,
    required this.theme,
    required this.onDismiss,
  });
  
  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cs = widget.theme.colorScheme;
    
    return Positioned(
      bottom: widget.position == ToastPosition.bottom
          ? mediaQuery.padding.bottom + SMTokens.s16
          : null,
      top: widget.position == ToastPosition.top
          ? mediaQuery.padding.top + SMTokens.s16
          : null,
      left: SMTokens.s4,
      right: SMTokens.s4,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Material(
            color: cs.inverseSurface.withOpacity(0.9),
            borderRadius: SMTokens.rFull,
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SMTokens.s4,
                vertical: SMTokens.s3,
              ),
              child: Text(
                widget.message,
                style: widget.theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onInverseSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ToastPosition {
  top,
  bottom,
}