import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Responsive layout builder
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < SMTokens.breakpointSm;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= SMTokens.breakpointSm && width < SMTokens.breakpointMd;
  }
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= SMTokens.breakpointMd;
  
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= SMTokens.breakpointMd && desktop != null) {
      return desktop;
    } else if (width >= SMTokens.breakpointSm && tablet != null) {
      return tablet;
    }
    return mobile;
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= SMTokens.breakpointMd && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= SMTokens.breakpointSm && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = SMTokens.s4,
    this.runSpacing = SMTokens.s4,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio = 1.0,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveLayout.value(
          context,
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
        );
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive row that wraps on smaller screens
class ResponsiveRow extends StatelessWidget {
  final List<ResponsiveRowItem> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final bool wrapOnMobile;
  final bool wrapOnTablet;
  
  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = SMTokens.s4,
    this.runSpacing = SMTokens.s4,
    this.wrapOnMobile = true,
    this.wrapOnTablet = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final shouldWrap = ResponsiveLayout.value(
      context,
      mobile: wrapOnMobile,
      tablet: wrapOnTablet,
      desktop: false,
    );
    
    if (shouldWrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: WrapAlignment.values[mainAxisAlignment.index],
        crossAxisAlignment: WrapCrossAlignment.values[crossAxisAlignment.index],
        children: children.map((item) => item.child).toList(),
      );
    }
    
    final totalFlex = children.fold(0, (sum, item) => sum + (item.flex ?? 0));
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (children[i].flex != null && totalFlex > 0)
            Expanded(
              flex: children[i].flex!,
              child: children[i].child,
            )
          else
            children[i].child,
          if (i < children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class ResponsiveRowItem {
  final Widget child;
  final int? flex;
  
  const ResponsiveRowItem({
    required this.child,
    this.flex,
  });
}

/// Responsive padding that adjusts based on screen size
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry mobile;
  final EdgeInsetsGeometry? tablet;
  final EdgeInsetsGeometry? desktop;
  
  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = const EdgeInsets.all(SMTokens.s4),
    this.tablet,
    this.desktop,
  });
  
  factory ResponsivePadding.symmetric({
    Key? key,
    required Widget child,
    double mobileHorizontal = SMTokens.s4,
    double mobileVertical = SMTokens.s4,
    double? tabletHorizontal,
    double? tabletVertical,
    double? desktopHorizontal,
    double? desktopVertical,
  }) {
    return ResponsivePadding(
      key: key,
      mobile: EdgeInsets.symmetric(
        horizontal: mobileHorizontal,
        vertical: mobileVertical,
      ),
      tablet: tabletHorizontal != null || tabletVertical != null
          ? EdgeInsets.symmetric(
              horizontal: tabletHorizontal ?? mobileHorizontal,
              vertical: tabletVertical ?? mobileVertical,
            )
          : null,
      desktop: desktopHorizontal != null || desktopVertical != null
          ? EdgeInsets.symmetric(
              horizontal: desktopHorizontal ?? tabletHorizontal ?? mobileHorizontal,
              vertical: desktopVertical ?? tabletVertical ?? mobileVertical,
            )
          : null,
      child: child,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveLayout.value(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive container with max width constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? SMTokens.breakpointMd,
        ),
        child: child,
      ),
    );
  }
}