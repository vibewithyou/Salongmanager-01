import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Base card component with consistent styling
class SMCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  
  const SMCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final content = Container(
      padding: padding ?? const EdgeInsets.all(SMTokens.s4),
      child: child,
    );
    
    return Container(
      margin: margin ?? const EdgeInsets.all(SMTokens.s2),
      decoration: BoxDecoration(
        color: color ?? cs.surface,
        borderRadius: borderRadius ?? SMTokens.rLg,
        border: border,
        boxShadow: elevation != null
            ? elevation! > 0
                ? SMTokens.shadowSm
                : null
            : boxShadow ?? SMTokens.shadowSm,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              borderRadius: borderRadius ?? SMTokens.rLg,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? SMTokens.rLg,
                child: content,
              ),
            )
          : content,
    );
  }
}

/// List card for displaying items in a list
class SMListCard extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool selected;
  
  const SMListCard({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.color,
    this.selected = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return SMCard(
      color: selected ? cs.primary.withOpacity(0.08) : color,
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(SMTokens.s3),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: SMTokens.s3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: selected ? cs.primary : null,
                  ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: SMTokens.s1),
                  DefaultTextStyle(
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: SMTokens.s3),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Feature card for highlighting services or features
class SMFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool compact;
  
  const SMFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    return SMCard(
      onTap: onTap,
      color: backgroundColor,
      padding: EdgeInsets.all(compact ? SMTokens.s3 : SMTokens.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(SMTokens.s3),
            decoration: BoxDecoration(
              color: (iconColor ?? cs.primary).withOpacity(0.1),
              borderRadius: SMTokens.rMd,
            ),
            child: Icon(
              icon,
              size: compact ? 24 : 32,
              color: iconColor ?? cs.primary,
            ),
          ),
          SizedBox(height: compact ? SMTokens.s2 : SMTokens.s3),
          Text(
            title,
            style: compact
                ? theme.textTheme.labelLarge
                : theme.textTheme.titleMedium,
            textAlign: compact ? TextAlign.center : TextAlign.start,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null && !compact) ...[
            const SizedBox(height: SMTokens.s2),
            Text(
              description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Info card for displaying important information
class SMInfoCard extends StatelessWidget {
  final Widget content;
  final InfoCardType type;
  final IconData? icon;
  final String? title;
  final List<Widget>? actions;
  final bool dismissible;
  final VoidCallback? onDismiss;
  
  const SMInfoCard({
    super.key,
    required this.content,
    this.type = InfoCardType.info,
    this.icon,
    this.title,
    this.actions,
    this.dismissible = false,
    this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final (bgColor, fgColor, defaultIcon) = switch (type) {
      InfoCardType.info => (cs.primary.withOpacity(0.1), cs.primary, Icons.info_outline),
      InfoCardType.success => (SMTokens.success.withOpacity(0.1), SMTokens.success, Icons.check_circle_outline),
      InfoCardType.warning => (SMTokens.warning.withOpacity(0.1), SMTokens.warning, Icons.warning_amber_rounded),
      InfoCardType.error => (cs.errorContainer, cs.onErrorContainer, Icons.error_outline),
    };
    
    final card = SMCard(
      color: bgColor,
      elevation: 0,
      border: Border.all(color: fgColor.withOpacity(0.2)),
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon ?? defaultIcon,
                color: fgColor,
                size: 20,
              ),
              const SizedBox(width: SMTokens.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: fgColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SMTokens.s1),
                    ],
                    DefaultTextStyle(
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: type == InfoCardType.error ? cs.onErrorContainer : cs.onSurface,
                      ),
                      child: content,
                    ),
                  ],
                ),
              ),
              if (dismissible) ...[
                const SizedBox(width: SMTokens.s2),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: fgColor),
                  onPressed: onDismiss,
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    minWidth: 32,
                  ),
                ),
              ],
            ],
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            const SizedBox(height: SMTokens.s3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (int i = 0; i < actions!.length; i++) ...[
                  actions![i],
                  if (i < actions!.length - 1) const SizedBox(width: SMTokens.s2),
                ],
              ],
            ),
          ],
        ],
      ),
    );
    
    return card;
  }
}

enum InfoCardType {
  info,
  success,
  warning,
  error,
}