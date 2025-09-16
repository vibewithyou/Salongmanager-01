import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/tokens.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/settings/theme_settings_page.dart';
import 'common/ui/empty_state.dart';
import 'common/layout/page_scaffold.dart';

/// Main app widget
class SalonManagerApp extends ConsumerWidget {
  const SalonManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    
    // Set system UI overlay style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: themeState.mode == ThemeMode.dark ||
                (themeState.mode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: themeState.mode == ThemeMode.dark ||
                (themeState.mode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark)
            ? const Color(0xFF0E0E0E)
            : Colors.white,
        systemNavigationBarIconBrightness: themeState.mode == ThemeMode.dark ||
                (themeState.mode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    
    return MaterialApp.router(
      title: 'SalonManager',
      debugShowCheckedModeBanner: false,
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: themeState.mode,
      routerConfig: _router,
      // Localization support
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
        // TODO(ASK): Add more locales as needed
      ],
      // Enable RTL support when locale changes
      builder: (context, child) {
        return Directionality(
          textDirection: _getTextDirection(context),
          child: child!,
        );
      },
    );
  }
  
  TextDirection _getTextDirection(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // Add RTL languages here
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(locale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

// Router configuration
final _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, __) => '/dashboard',
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingsPage(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const NewBookingPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => const CustomersPage(),
    ),
    GoRoute(
      path: '/services',
      builder: (context, state) => const ServicesPage(),
    ),
    GoRoute(
      path: '/staff',
      builder: (context, state) => const StaffPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'theme',
          builder: (context, state) => const ThemeSettingsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchPage(),
    ),
  ],
  errorBuilder: (context, state) => ErrorPage(error: state.error),
);

// Placeholder pages - to be implemented

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Bookings')),
    );
  }
}

class NewBookingPage extends StatelessWidget {
  const NewBookingPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('New Booking')),
    );
  }
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Customers')),
    );
  }
}

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Services')),
    );
  }
}

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Staff')),
    );
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      title: 'Einstellungen',
      padding: const EdgeInsets.all(SMTokens.s4),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme & Erscheinungsbild'),
            subtitle: const Text('Farben und Design anpassen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/theme'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Sprache & Region'),
            subtitle: const Text('Deutsch (Deutschland)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Benachrichtigungen'),
            subtitle: const Text('Push- und E-Mail-Einstellungen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Search')),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Exception? error;
  
  const ErrorPage({super.key, this.error});
  
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Fehler',
      body: Center(
        child: EmptyState.error(
          message: error?.toString() ?? 'Ein unbekannter Fehler ist aufgetreten',
          onRetry: () => context.go('/'),
        ),
      ),
    );
  }
}