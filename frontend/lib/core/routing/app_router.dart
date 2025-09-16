import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/settings/theme_settings_page.dart';
import '../../features/booking/wizard/booking_wizard_page.dart';
import '../../features/legal/impressum_page.dart';
import '../../features/legal/datenschutz_page.dart';
import '../../features/legal/agb_page.dart';
import '../../features/rbac/admin_shell.dart';
import '../app_scaffold.dart';
import 'guards.dart';

/// Main app router configuration
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // TODO: Add authentication redirect logic
      return null;
    },
    routes: [
      // Main app routes
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppScaffold(
          child: DashboardPage(),
        ),
      ),
      
      // Booking routes
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const AppScaffold(
          child: BookingsPage(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const AppScaffold(
              child: BookingWizardPage(),
            ),
          ),
          GoRoute(
            path: 'success',
            builder: (context, state) => const AppScaffold(
              child: BookingSuccessPage(),
            ),
          ),
        ],
      ),
      
      // Customer routes
      GoRoute(
        path: '/customers',
        builder: (context, state) => const AppScaffold(
          child: CustomersPage(),
        ),
      ),
      
      // Services routes
      GoRoute(
        path: '/services',
        builder: (context, state) => const AppScaffold(
          child: ServicesPage(),
        ),
      ),
      
      // Staff routes
      GoRoute(
        path: '/staff',
        builder: (context, state) => const AppScaffold(
          child: StaffPage(),
        ),
      ),
      
      // Admin routes (RBAC protected)
      GoRoute(
        path: '/admin',
        redirect: (_, __) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AppScaffold(
          child: AdminShell(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      GoRoute(
        path: '/admin/staff',
        builder: (context, state) => const AppScaffold(
          child: AdminStaffPage(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      GoRoute(
        path: '/admin/schedule',
        builder: (context, state) => const AppScaffold(
          child: AdminSchedulePage(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      GoRoute(
        path: '/admin/services',
        builder: (context, state) => const AppScaffold(
          child: AdminServicesPage(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      GoRoute(
        path: '/admin/pos',
        builder: (context, state) => const AppScaffold(
          child: AdminPosPage(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      GoRoute(
        path: '/admin/inventory',
        builder: (context, state) => const AppScaffold(
          child: AdminInventoryPage(),
        ),
        redirect: (context, state) => requireRole(context, ['owner', 'manager']),
      ),
      
      // Settings routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppScaffold(
          child: SettingsPage(),
        ),
        routes: [
          GoRoute(
            path: 'theme',
            builder: (context, state) => const AppScaffold(
              child: ThemeSettingsPage(),
            ),
          ),
        ],
      ),
      
      // Legal pages
      GoRoute(
        path: '/impressum',
        builder: (context, state) => const AppScaffold(
          child: ImpressumPage(),
          showAppBar: true,
          showDrawer: false,
          showBottomNav: false,
        ),
      ),
      GoRoute(
        path: '/datenschutz',
        builder: (context, state) => const AppScaffold(
          child: DatenschutzPage(),
          showAppBar: true,
          showDrawer: false,
          showBottomNav: false,
        ),
      ),
      GoRoute(
        path: '/agb',
        builder: (context, state) => const AppScaffold(
          child: AgbPage(),
          showAppBar: true,
          showDrawer: false,
          showBottomNav: false,
        ),
      ),
    ],
    errorBuilder: (context, state) => const AppScaffold(
      child: ErrorPage(),
    ),
  );
});

// Placeholder pages - to be implemented

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Termine',
      body: Center(child: Text('Bookings Page - TODO')),
    );
  }
}

class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Buchung erfolgreich',
      body: Center(child: Text('Booking Success Page - TODO')),
    );
  }
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Kunden',
      body: Center(child: Text('Customers Page - TODO')),
    );
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Leistungen',
      body: Center(child: Text('Services Page - TODO')),
    );
  }
}

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Team',
      body: Center(child: Text('Staff Page - TODO')),
    );
  }
}

class AdminStaffPage extends StatelessWidget {
  const AdminStaffPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Team & Rollen',
      body: Center(child: Text('Admin Staff Page - TODO')),
    );
  }
}

class AdminSchedulePage extends StatelessWidget {
  const AdminSchedulePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Dienstpläne',
      body: Center(child: Text('Admin Schedule Page - TODO')),
    );
  }
}

class AdminServicesPage extends StatelessWidget {
  const AdminServicesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Leistungen & Preise',
      body: Center(child: Text('Admin Services Page - TODO')),
    );
  }
}

class AdminPosPage extends StatelessWidget {
  const AdminPosPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'POS & Kasse',
      body: Center(child: Text('Admin POS Page - TODO')),
    );
  }
}

class AdminInventoryPage extends StatelessWidget {
  const AdminInventoryPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Inventar',
      body: Center(child: Text('Admin Inventory Page - TODO')),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Einstellungen',
      body: Center(child: Text('Settings Page - TODO')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      title: 'Seite nicht gefunden',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64),
            SizedBox(height: 16),
            Text('Die angeforderte Seite konnte nicht gefunden werden.'),
            SizedBox(height: 16),
            // TODO: Add back button
          ],
        ),
      ),
    );
  }
}
