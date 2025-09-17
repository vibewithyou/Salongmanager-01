import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Empty state widget for lists, searches, and content areas
class EmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment alignment;
  
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.padding,
    this.alignment = MainAxisAlignment.center,
  });
  
  factory EmptyState.search({
    String? searchTerm,
    Widget? action,
  }) {
    return EmptyState(
      icon: const Icon(Icons.search_off, size: 64),
      title: 'Keine Ergebnisse',
      subtitle: searchTerm != null
          ? 'Keine Treffer für "$searchTerm" gefunden'
          : 'Versuche es mit anderen Suchbegriffen',
      action: action,
    );
  }
  
  factory EmptyState.noData({
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return EmptyState(
      icon: const Icon(Icons.inbox_outlined, size: 64),
      title: title,
      subtitle: subtitle,
      action: action,
    );
  }
  
  factory EmptyState.error({
    String? message,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: const Icon(Icons.error_outline, size: 64),
      title: 'Etwas ist schiefgelaufen',
      subtitle: message ?? 'Bitte versuche es später erneut',
      action: onRetry != null
          ? TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            )
          : null,
    );
  }
  
  factory EmptyState.offline({
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: const Icon(Icons.cloud_off, size: 64),
      title: 'Keine Internetverbindung',
      subtitle: 'Überprüfe deine Verbindung und versuche es erneut',
      action: onRetry != null
          ? TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Erneut versuchen'),
            )
          : null,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Container(
      alignment: Alignment.center,
      padding: padding ?? const EdgeInsets.all(SMTokens.s8),
      child: Column(
        mainAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            IconTheme(
              data: IconThemeData(
                color: cs.onSurfaceVariant.withOpacity(0.5),
                size: 64,
              ),
              child: icon!,
            ),
          const SizedBox(height: SMTokens.s4),
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: SMTokens.s2),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: SMTokens.s6),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Illustrated empty state with custom illustration
class IllustratedEmptyState extends StatelessWidget {
  final Widget illustration;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double illustrationHeight;
  
  const IllustratedEmptyState({
    super.key,
    required this.illustration,
    required this.title,
    this.subtitle,
    this.action,
    this.illustrationHeight = 200,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SMTokens.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: illustrationHeight,
              child: illustration,
            ),
            const SizedBox(height: SMTokens.s6),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SMTokens.s3),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: SMTokens.s8),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}