import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme_controller.dart';
import 'core/theme/tokens.dart';
import 'core/routing/app_router.dart';
import 'common/ui/sm_toast.dart';

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
      routerConfig: ref.watch(appRouterProvider),
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
