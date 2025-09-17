import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/tokens.dart';

/// Toast notification types
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast data class
class ToastData {
  final String message;
  final ToastType type;
  final String? title;
  final Duration? duration;
  final VoidCallback? onTap;
  final bool dismissible;

  const ToastData({
    required this.message,
    required this.type,
    this.title,
    this.duration,
    this.onTap,
    this.dismissible = true,
  });
}

/// Toast controller provider
final toastControllerProvider = StateNotifierProvider<ToastController, List<ToastData>>((ref) {
  return ToastController();
});

/// Toast controller
class ToastController extends StateNotifier<List<ToastData>> {
  ToastController() : super([]);

  void show(ToastData toast) {
    state = [...state, toast];
    
    // Auto dismiss after duration
    if (toast.duration != null) {
      Future.delayed(toast.duration!, () {
        dismiss(toast);
      });
    }
  }

  void dismiss(ToastData toast) {
    state = state.where((t) => t != toast).toList();
  }

  void dismissAll() {
    state = [];
  }

  // Convenience methods
  void showSuccess(String message, {String? title, Duration? duration}) {
    show(ToastData(
      message: message,
      type: ToastType.success,
      title: title,
      duration: duration ?? const Duration(seconds: 4),
    ));
  }

  void showError(String message, {String? title, Duration? duration}) {
    show(ToastData(
      message: message,
      type: ToastType.error,
      title: title,
      duration: duration ?? const Duration(seconds: 6),
    ));
  }

  void showWarning(String message, {String? title, Duration? duration}) {
    show(ToastData(
      message: message,
      type: ToastType.warning,
      title: title,
      duration: duration ?? const Duration(seconds: 5),
    ));
  }

  void showInfo(String message, {String? title, Duration? duration}) {
    show(ToastData(
      message: message,
      type: ToastType.info,
      title: title,
      duration: duration ?? const Duration(seconds: 4),
    ));
  }
}

/// Global toast overlay
class GlobalToasts extends ConsumerWidget {
  const GlobalToasts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastControllerProvider);

    return Positioned(
      top: MediaQuery.of(context).padding.top + SMTokens.s4,
      left: SMTokens.s4,
      right: SMTokens.s4,
      child: Column(
        children: toasts.map((toast) => Padding(
          padding: const EdgeInsets.only(bottom: SMTokens.s2),
          child: SMToast(
            data: toast,
            onDismiss: () => ref.read(toastControllerProvider.notifier).dismiss(toast),
          ),
        )).toList(),
      ),
    );
  }
}

/// Individual toast widget
class SMToast extends StatefulWidget {
  final ToastData data;
  final VoidCallback? onDismiss;

  const SMToast({
    super.key,
    required this.data,
    this.onDismiss,
  });

  @override
  State<SMToast> createState() => _SMToastState();
}

class _SMToastState extends State<SMToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (icon, bgColor, fgColor) = _getToastStyle(widget.data.type, cs);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Material(
              elevation: 8,
              borderRadius: SMTokens.rLg,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: SMTokens.rLg,
                  border: Border.all(
                    color: fgColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: widget.data.onTap,
                  borderRadius: SMTokens.rLg,
                  child: Padding(
                    padding: const EdgeInsets.all(SMTokens.s4),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: fgColor,
                          size: 24,
                        ),
                        const SizedBox(width: SMTokens.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.data.title != null) ...[
                                Text(
                                  widget.data.title!,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: fgColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: SMTokens.s1),
                              ],
                              Text(
                                widget.data.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: fgColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.data.dismissible) ...[
                          const SizedBox(width: SMTokens.s2),
                          IconButton(
                            onPressed: () {
                              _animationController.reverse().then((_) {
                                widget.onDismiss?.call();
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: fgColor,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minHeight: 32,
                              minWidth: 32,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (IconData, Color, Color) _getToastStyle(ToastType type, ColorScheme cs) {
    switch (type) {
      case ToastType.success:
        return (
          Icons.check_circle,
          SMTokens.success.withOpacity(0.1),
          SMTokens.success,
        );
      case ToastType.error:
        return (
          Icons.error,
          cs.errorContainer,
          cs.onErrorContainer,
        );
      case ToastType.warning:
        return (
          Icons.warning,
          SMTokens.warning.withOpacity(0.1),
          SMTokens.warning,
        );
      case ToastType.info:
        return (
          Icons.info,
          cs.primary.withOpacity(0.1),
          cs.primary,
        );
    }
  }
}

/// Toast extension for easy access
extension ToastExtension on WidgetRef {
  ToastController get toast => read(toastControllerProvider.notifier);
}
