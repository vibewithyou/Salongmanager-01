import 'package:flutter/material.dart';

/// Performance-optimized list widget with RepaintBoundary
class PerformanceList extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  const PerformanceList({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.itemExtent,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemExtent: itemExtent,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('list_item_$index'),
          child: children[index],
        );
      },
    );
  }
}

/// Performance-optimized grid widget with RepaintBoundary
class PerformanceGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  const PerformanceGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          key: ValueKey('grid_item_$index'),
          child: children[index],
        );
      },
    );
  }
}

/// Performance-optimized card widget
class PerformanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? shadowColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const PerformanceCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.shadowColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        margin: margin,
        color: color,
        shadowColor: shadowColor,
        elevation: elevation,
        shape: borderRadius != null
            ? RoundedRectangleBorder(borderRadius: borderRadius!)
            : null,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: border,
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Performance-optimized list tile
class PerformanceListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final bool selected;
  final Color? selectedColor;
  final Color? iconColor;
  final Color? textColor;
  final Color? tileColor;
  final Color? selectedTileColor;

  const PerformanceListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.contentPadding,
    this.enabled = true,
    this.selected = false,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.tileColor,
    this.selectedTileColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: contentPadding,
        enabled: enabled,
        selected: selected,
        selectedColor: selectedColor,
        iconColor: iconColor,
        textColor: textColor,
        tileColor: tileColor,
        selectedTileColor: selectedTileColor,
      ),
    );
  }
}

/// Performance-optimized container with conditional rendering
class ConditionalContainer extends StatelessWidget {
  final bool condition;
  final Widget child;
  final Widget? fallback;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const ConditionalContainer({
    super.key,
    required this.condition,
    required this.child,
    this.fallback,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    if (!condition) {
      return fallback ?? const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}
