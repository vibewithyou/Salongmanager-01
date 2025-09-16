import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/router.dart';
import 'features/salon_profile/state/salon_controller.dart';

class SalonManagerApp extends ConsumerWidget {
  const SalonManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter.build(ref);
    final salon = ref.watch(salonControllerProvider).profile;

    final light = AppTheme.overrideWithSalon(
      AppTheme.lightTheme,
      primaryHex: salon?.primaryColor,
      secondaryHex: salon?.secondaryColor,
    );
    final dark = AppTheme.overrideWithSalon(
      AppTheme.darkTheme,
      primaryHex: salon?.primaryColor,
      secondaryHex: salon?.secondaryColor,
    );

    return MaterialApp.router(
      title: salon?.name ?? 'SalonManager',
      theme: light,
      darkTheme: dark,
      routerConfig: router,
    );
  }
}

