import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/salon_profile/ui/salon_page.dart';
import '../../features/booking/ui/booking_list_screen.dart';
import '../../features/booking/ui/booking_wizard_screen.dart';
import '../../features/staff/ui/staff_calendar_page.dart';
import '../../features/customer_profile/ui/customer_list_page.dart';
import '../../features/customer_profile/ui/customer_detail_page.dart';
import '../../features/billing_pos/ui/pos_page.dart';
import '../../features/billing_pos/ui/z_report_page.dart';
import '../../features/search_map/ui/search_map_page.dart';
import '../../features/inventory/ui/inventory_page.dart';
import 'go_router_refresh_stream.dart';

class AppRouter {
  static GoRouter build(WidgetRef ref) {
    // Create a stream that emits when auth state changes
    final authNotifier = ref.watch(authControllerProvider.notifier);
    final refreshStream = authNotifier.stream;
    
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(refreshStream),
      redirect: (context, state) {
        final auth = ref.read(authControllerProvider);
        final loggingIn = state.matchedLocation == '/login';
        final loggedIn = auth.user != null;

        if (!loggedIn && !loggingIn) return '/login';
        if (loggedIn && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (ctx, st) => const LoginScreen()),
        GoRoute(path: '/', builder: (ctx, st) => const SalonPage()),
        GoRoute(path: '/bookings', builder: (ctx, st) => const BookingListScreen()),
        GoRoute(path: '/book', builder: (ctx, st) => const BookingWizardScreen()),
        GoRoute(path: '/staff/schedule', builder: (ctx, st) => const StaffCalendarPage()),
        GoRoute(path: '/customers', builder: (ctx, st) => const CustomerListPage()),
        GoRoute(
          path: '/customers/:id',
          builder: (ctx, st) {
            final id = int.parse(st.pathParameters['id']!);
            return CustomerDetailPage(id: id);
          },
        ),
        GoRoute(path: '/pos', builder: (ctx, st) => const PosPage()),
        GoRoute(path: '/pos/z-report', builder: (ctx, st) => const ZReportPage()),
        GoRoute(path: '/inventory', builder: (ctx, st) => const InventoryPage()),
        GoRoute(path: '/search', builder: (ctx, st) => const SearchMapPage()),
      ],
    );
  }
}