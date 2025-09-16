import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Base page scaffold with consistent layout
class PageScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final EdgeInsetsGeometry? padding;
  
  const PageScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.padding,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');
  
  @override
  Widget build(BuildContext context) {
    final hasAppBar = title != null || titleWidget != null || actions != null;
    
    return Scaffold(
      appBar: hasAppBar
          ? AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
              centerTitle: centerTitle,
              elevation: elevation,
              bottom: bottom,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
            )
          : null,
      body: SafeArea(
        child: padding != null
            ? Padding(padding: padding!, child: body)
            : body,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Responsive page scaffold that adapts to screen size
class ResponsivePageScaffold extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? desktopBody;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? navigationRail;
  final Widget? drawer;
  final bool showNavigationRail;
  final EdgeInsetsGeometry? padding;
  
  const ResponsivePageScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.mobileBody,
    this.tabletBody,
    this.desktopBody,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.navigationRail,
    this.drawer,
    this.showNavigationRail = true,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < SMTokens.breakpointSm;
        final isTablet = width >= SMTokens.breakpointSm && width < SMTokens.breakpointMd;
        final isDesktop = width >= SMTokens.breakpointMd;
        
        // Select appropriate body based on screen size
        Widget body = mobileBody;
        if (isTablet && tabletBody != null) {
          body = tabletBody!;
        } else if (isDesktop && desktopBody != null) {
          body = desktopBody!;
        }
        
        // Add padding if specified
        if (padding != null) {
          body = Padding(padding: padding!, child: body);
        }
        
        // Desktop layout with navigation rail
        if (isDesktop && showNavigationRail && navigationRail != null) {
          return Scaffold(
            appBar: AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              actions: actions,
            ),
            body: SafeArea(
              child: Row(
                children: [
                  navigationRail!,
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              ),
            ),
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
          );
        }
        
        // Mobile/Tablet layout
        return PageScaffold(
          title: title,
          titleWidget: titleWidget,
          actions: actions,
          body: body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
        );
      },
    );
  }
}

/// Tabbed page scaffold for pages with tabs
class TabbedPageScaffold extends StatelessWidget {
  final String? title;
  final List<Tab> tabs;
  final List<Widget> tabViews;
  final List<Widget>? actions;
  final TabController? controller;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onTabChanged;
  
  const TabbedPageScaffold({
    super.key,
    this.title,
    required this.tabs,
    required this.tabViews,
    this.actions,
    this.controller,
    this.isScrollable = false,
    this.padding,
    this.onTabChanged,
  }) : assert(tabs.length == tabViews.length,
            'tabs and tabViews must have the same length');
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: PageScaffold(
        title: title,
        actions: actions,
        bottom: TabBar(
          tabs: tabs,
          controller: controller,
          isScrollable: isScrollable,
          onTap: onTabChanged,
        ),
        body: TabBarView(
          controller: controller,
          children: [
            for (final view in tabViews)
              padding != null
                  ? Padding(padding: padding!, child: view)
                  : view,
          ],
        ),
      ),
    );
  }
}

/// Sliver page scaffold for advanced scrolling effects
class SliverPageScaffold extends StatelessWidget {
  final Widget? title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final List<Widget> slivers;
  final double? expandedHeight;
  final bool floating;
  final bool pinned;
  final bool snap;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  
  const SliverPageScaffold({
    super.key,
    this.title,
    this.flexibleSpace,
    this.actions,
    required this.slivers,
    this.expandedHeight,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: title,
            actions: actions,
            flexibleSpace: flexibleSpace,
            expandedHeight: expandedHeight,
            floating: floating,
            pinned: pinned,
            snap: snap,
          ),
          ...slivers,
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}