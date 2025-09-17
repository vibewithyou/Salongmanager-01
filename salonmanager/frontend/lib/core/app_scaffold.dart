import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../common/ui/sm_toast.dart';
import '../common/ui/consent_banner.dart';
import '../common/layout/page_scaffold.dart';
import '../common/layout/responsive_layout.dart';
import 'theme/tokens.dart';

/// Global app scaffold with navigation and providers
class AppScaffold extends ConsumerWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool showDrawer;
  final bool showBottomNav;

  const AppScaffold({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = true,
    this.showDrawer = true,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDesktop = MediaQuery.of(context).size.width >= SMTokens.breakpointMd;

    return Scaffold(
      appBar: showAppBar ? _buildAppBar(context, theme, cs) : null,
      drawer: showDrawer && !isDesktop ? _buildDrawer(context) : null,
      endDrawer: showDrawer && isDesktop ? _buildEndDrawer(context) : null,
      bottomNavigationBar: showBottomNav && !isDesktop ? _buildBottomNav(context) : null,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          child,
          const GlobalToasts(),
          const ConsentBanner(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme cs) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: SMTokens.rSm,
            ),
            child: Icon(
              Icons.content_cut,
              color: cs.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: SMTokens.s3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? 'SalonManager',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                ),
              ),
              Text(
                'Beauty & Wellness',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: actions ?? [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Navigate to notifications
          },
          tooltip: 'Benachrichtigungen',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push('/settings'),
          tooltip: 'Einstellungen',
        ),
        const SizedBox(width: SMTokens.s2),
      ],
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Drawer(
      child: Column(
        children: [
          _buildDrawerHeader(theme, cs),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Termine',
                  route: '/bookings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outlined,
                  title: 'Kunden',
                  route: '/customers',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.work_outline,
                  title: 'Leistungen',
                  route: '/services',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.group_outlined,
                  title: 'Team',
                  route: '/staff',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administration',
                  route: '/admin',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Einstellungen',
                  route: '/settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Drawer(
      width: 280,
      child: Column(
        children: [
          _buildDrawerHeader(theme, cs),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  route: '/dashboard',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Termine',
                  route: '/bookings',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people_outlined,
                  title: 'Kunden',
                  route: '/customers',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.work_outline,
                  title: 'Leistungen',
                  route: '/services',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.group_outlined,
                  title: 'Team',
                  route: '/staff',
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administration',
                  route: '/admin',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Einstellungen',
                  route: '/settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme, ColorScheme cs) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.onPrimary,
              borderRadius: SMTokens.rLg,
            ),
            child: Icon(
              Icons.content_cut,
              color: cs.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: SMTokens.s3),
          Text(
            'SalonManager',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Beauty & Wellness',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentRoute = GoRouterState.of(context).uri.path;

    return ListTile(
      leading: Icon(
        icon,
        color: currentRoute == route ? cs.primary : cs.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: currentRoute == route ? cs.primary : cs.onSurface,
          fontWeight: currentRoute == route ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: currentRoute == route,
      selectedTileColor: cs.primary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        if (currentRoute != route) {
          context.go(route);
        }
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentRoute = GoRouterState.of(context).uri.path;

    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentRoute),
      onDestinationSelected: (index) {
        final route = _getRouteForIndex(index);
        if (route != null && currentRoute != route) {
          context.go(route);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Termine',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outlined),
          selectedIcon: Icon(Icons.people),
          label: 'Kunden',
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work),
          label: 'Leistungen',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_outlined),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'Mehr',
        ),
      ],
    );
  }

  int _getSelectedIndex(String currentRoute) {
    switch (currentRoute) {
      case '/dashboard':
        return 0;
      case '/bookings':
        return 1;
      case '/customers':
        return 2;
      case '/services':
        return 3;
      default:
        return 0;
    }
  }

  String? _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/dashboard';
      case 1:
        return '/bookings';
      case 2:
        return '/customers';
      case 3:
        return '/services';
      case 4:
        return '/settings';
      default:
        return null;
    }
  }
}
