// App root for SalonManager Flutter client
// Purpose: Provide MaterialApp with theming and routing

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/router.dart';

class SalonManagerApp extends StatelessWidget {
  const SalonManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = buildRouter();
    return MaterialApp.router(
      title: 'SalonManager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

