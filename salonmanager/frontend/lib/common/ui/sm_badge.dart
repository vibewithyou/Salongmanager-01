import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Badge widget for displaying counts or status indicators
class SMBadge extends StatelessWidget {
  final Widget child;
  final Widget? label;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLabelVisible;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final double? largeSize;
  final double? smallSize;
  
  const SMBadge({
    super.key,
    required this.child,
    this.label,
    this.backgroundColor,
    this.textColor,
    this.isLabelVisible = true,
    this.alignment = AlignmentDirectional.topEnd,
    this.padding,
    this.largeSize,
    this.smallSize,
  });
  
  factory SMBadge.count({
    Key? key,
    required Widget child,
    required int count,
    Color? backgroundColor,
    Color? textColor,
    bool showZero = false,
    AlignmentGeometry alignment = AlignmentDirectional.topEnd,
  }) {
    return SMBadge(
      key: key,
      child: child,
      label: count > 99
          ? const Text('99+')
          : Text(count.toString()),
      backgroundColor: backgroundColor,
      textColor: textColor,
      isLabelVisible: showZero || count > 0,
      alignment: alignment,
    );
  }
  
  factory SMBadge.dot({
    Key? key,
    required Widget child,
    Color? backgroundColor,
    bool isVisible = true,
    AlignmentGeometry alignment = AlignmentDirectional.topEnd,
    double size = 8,
  }) {
    return SMBadge(
      key: key,
      child: child,
      backgroundColor: backgroundColor,
      isLabelVisible: isVisible,
      alignment: alignment,
      smallSize: size,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (!isLabelVisible) {
      return child;
    }
    
    return Badge(
      label: label,
      backgroundColor: backgroundColor,
      textColor: textColor,
      alignment: alignment,
      padding: padding,
      largeSize: largeSize,
      smallSize: smallSize,
      child: child,
    );
  }
}

/// Status badge for displaying status information
class SMStatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final bool outlined;
  final double? fontSize;
  
  const SMStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.outlined = false,
    this.fontSize,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    final (bgColor, fgColor) = switch (type) {
      StatusType.active => (SMTokens.success, SMTokens.white),
      StatusType.pending => (SMTokens.warning, SMTokens.black),
      StatusType.inactive => (cs.surfaceVariant, cs.onSurfaceVariant),
      StatusType.error => (cs.error, cs.onError),
      StatusType.info => (cs.primary, cs.onPrimary),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SMTokens.s3,
        vertical: SMTokens.s1,
      ),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : bgColor,
        border: outlined ? Border.all(color: bgColor, width: 1) : null,
        borderRadius: SMTokens.rFull,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: outlined ? bgColor : fgColor,
          fontSize: fontSize ?? SMTokens.textXs,
          fontWeight: FontWeight.w600,
          letterSpacing: SMTokens.letterSpacingWide,
        ),
      ),
    );
  }
}

enum StatusType {
  active,
  pending,
  inactive,
  error,
  info,
}

/// Icon badge for adding badges to icons
class SMIconBadge extends StatelessWidget {
  final IconData icon;
  final Widget? badge;
  final double iconSize;
  final Color? iconColor;
  final bool showBadge;
  
  const SMIconBadge({
    super.key,
    required this.icon,
    this.badge,
    this.iconSize = 24,
    this.iconColor,
    this.showBadge = true,
  });
  
  factory SMIconBadge.count({
    Key? key,
    required IconData icon,
    required int count,
    double iconSize = 24,
    Color? iconColor,
    Color? badgeColor,
    bool showZero = false,
  }) {
    return SMIconBadge(
      key: key,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      showBadge: showZero || count > 0,
      badge: count > 0 || showZero
          ? SMBadge.count(
              count: count,
              backgroundColor: badgeColor,
              child: const SizedBox.shrink(),
            )
          : null,
    );
  }
  
  factory SMIconBadge.dot({
    Key? key,
    required IconData icon,
    double iconSize = 24,
    Color? iconColor,
    Color? dotColor,
    bool showDot = true,
  }) {
    return SMIconBadge(
      key: key,
      icon: icon,
      iconSize: iconSize,
      iconColor: iconColor,
      showBadge: showDot,
      badge: showDot
          ? SMBadge.dot(
              backgroundColor: dotColor,
              child: const SizedBox.shrink(),
            )
          : null,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: iconSize,
      color: iconColor,
    );
    
    if (!showBadge || badge == null) {
      return iconWidget;
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        iconWidget,
        Positioned(
          top: 0,
          right: 0,
          child: badge!,
        ),
      ],
    );
  }
}