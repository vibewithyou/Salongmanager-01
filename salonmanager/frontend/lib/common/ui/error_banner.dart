import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Error banner for displaying error messages
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Widget? action;
  final EdgeInsetsGeometry? margin;
  
  const ErrorBanner(
    this.message, {
    super.key,
    this.onDismiss,
    this.action,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      margin: margin ?? const EdgeInsets.all(SMTokens.s4),
      child: Material(
        color: cs.errorContainer,
        borderRadius: SMTokens.rMd,
        child: Padding(
          padding: const EdgeInsets.all(SMTokens.s3),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: cs.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: SMTokens.s3),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onErrorContainer,
                    fontSize: SMTokens.textSm,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: SMTokens.s2),
                action!,
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: SMTokens.s2),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cs.onErrorContainer,
                    size: 18,
                  ),
                  onPressed: onDismiss,
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
    );
  }
}

/// Warning banner for displaying warning messages
class WarningBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Widget? action;
  final EdgeInsetsGeometry? margin;
  
  const WarningBanner(
    this.message, {
    super.key,
    this.onDismiss,
    this.action,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warningColor = SMTokens.warning;
    final warningContainer = warningColor.withOpacity(0.15);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(SMTokens.s4),
      child: Material(
        color: warningContainer,
        borderRadius: SMTokens.rMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: warningColor.withOpacity(0.3),
            ),
            borderRadius: SMTokens.rMd,
          ),
          padding: const EdgeInsets.all(SMTokens.s3),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: warningColor,
                size: 20,
              ),
              const SizedBox(width: SMTokens.s3),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: SMTokens.textSm,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: SMTokens.s2),
                action!,
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: SMTokens.s2),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cs.onSurface,
                    size: 18,
                  ),
                  onPressed: onDismiss,
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
    );
  }
}

/// Info banner for displaying informational messages
class InfoBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Widget? action;
  final EdgeInsetsGeometry? margin;
  
  const InfoBanner(
    this.message, {
    super.key,
    this.onDismiss,
    this.action,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      margin: margin ?? const EdgeInsets.all(SMTokens.s4),
      child: Material(
        color: cs.primary.withOpacity(0.1),
        borderRadius: SMTokens.rMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: cs.primary.withOpacity(0.2),
            ),
            borderRadius: SMTokens.rMd,
          ),
          padding: const EdgeInsets.all(SMTokens.s3),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: cs.primary,
                size: 20,
              ),
              const SizedBox(width: SMTokens.s3),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: SMTokens.textSm,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: SMTokens.s2),
                action!,
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: SMTokens.s2),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cs.onSurface,
                    size: 18,
                  ),
                  onPressed: onDismiss,
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
    );
  }
}

/// Success banner for displaying success messages
class SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Widget? action;
  final EdgeInsetsGeometry? margin;
  
  const SuccessBanner(
    this.message, {
    super.key,
    this.onDismiss,
    this.action,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final successColor = SMTokens.success;
    final successContainer = successColor.withOpacity(0.15);
    
    return Container(
      margin: margin ?? const EdgeInsets.all(SMTokens.s4),
      child: Material(
        color: successContainer,
        borderRadius: SMTokens.rMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: successColor.withOpacity(0.3),
            ),
            borderRadius: SMTokens.rMd,
          ),
          padding: const EdgeInsets.all(SMTokens.s3),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: successColor,
                size: 20,
              ),
              const SizedBox(width: SMTokens.s3),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: SMTokens.textSm,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: SMTokens.s2),
                action!,
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: SMTokens.s2),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: cs.onSurface,
                    size: 18,
                  ),
                  onPressed: onDismiss,
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
    );
  }
}