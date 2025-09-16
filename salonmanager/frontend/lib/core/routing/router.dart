import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/salon_profile/ui/home_screen.dart';
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
        GoRoute(path: '/', builder: (ctx, st) => const HomeScreen()),
      ],
    );
  }
}