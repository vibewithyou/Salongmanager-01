// Centralized theme configuration (Light/Dark) with Black/Gold palette
// TODO: Allow per-salon overrides via remote config or local settings

import 'package:flutter/material.dart';

class AppColors {
  static const Color gold = Color(0xFFFFC107); // Amber as gold-like accent
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.black,
        surface: AppColors.white,
        onPrimary: AppColors.black,
        onSurface: AppColors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
      ),
      scaffoldBackgroundColor: AppColors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.gold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.gold,
        secondary: AppColors.white,
        surface: AppColors.black,
        onPrimary: AppColors.black,
        onSurface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
      ),
      scaffoldBackgroundColor: AppColors.black,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
        ),
      ),
    );
  }

  static ThemeData overrideWithSalon(ThemeData base, {String? primaryHex, String? secondaryHex}) {
    Color? primary = _parseHex(primaryHex);
    Color? secondary = _parseHex(secondaryHex);
    final scheme = base.colorScheme.copyWith(
      primary: primary ?? base.colorScheme.primary,
      secondary: secondary ?? base.colorScheme.secondary,
    );
    return base.copyWith(colorScheme: scheme);
  }

  static Color? _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var v = hex.replaceAll('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse(v, radix: 16));
  }
}

