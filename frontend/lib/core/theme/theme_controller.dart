import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sm_theme.dart';
import 'salon_theme_overrides.dart';
import 'tokens.dart';

// Theme mode provider (light/dark/system)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Salon overrides provider
final salonOverridesProvider = StateProvider<SalonThemeOverrides?>((ref) => null);

// Main theme controller
final themeControllerProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController(ref);
});

class ThemeState {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final ThemeMode mode;
  final SalonThemeOverrides? overrides;
  
  const ThemeState({
    required this.lightTheme,
    required this.darkTheme,
    required this.mode,
    this.overrides,
  });
  
  ThemeState copyWith({
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    ThemeMode? mode,
    SalonThemeOverrides? overrides,
  }) {
    return ThemeState(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      mode: mode ?? this.mode,
      overrides: overrides ?? this.overrides,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  final Ref _ref;
  
  ThemeController(this._ref) : super(
    ThemeState(
      lightTheme: SMTheme.light(),
      darkTheme: SMTheme.dark(),
      mode: ThemeMode.system,
    ),
  ) {
    // Listen to theme mode changes
    _ref.listen(themeModeProvider, (previous, next) {
      state = state.copyWith(mode: next);
    });
    
    // Listen to salon overrides
    _ref.listen(salonOverridesProvider, (previous, next) {
      _applyOverrides(next);
    });
  }
  
  void setThemeMode(ThemeMode mode) {
    _ref.read(themeModeProvider.notifier).state = mode;
  }
  
  void setSalonOverrides(SalonThemeOverrides? overrides) {
    _ref.read(salonOverridesProvider.notifier).state = overrides;
  }
  
  void _applyOverrides(SalonThemeOverrides? overrides) {
    if (overrides == null) {
      // Reset to default themes
      state = state.copyWith(
        lightTheme: SMTheme.light(),
        darkTheme: SMTheme.dark(),
        overrides: null,
      );
      return;
    }
    
    // Apply overrides to color schemes
    var lightScheme = SMTheme.lightScheme;
    var darkScheme = SMTheme.darkScheme;
    
    if (overrides.primary != null) {
      lightScheme = lightScheme.copyWith(
        primary: overrides.primary,
        onPrimary: _getContrastColor(overrides.primary!),
      );
      darkScheme = darkScheme.copyWith(
        primary: overrides.primary,
        onPrimary: _getContrastColor(overrides.primary!),
      );
    }
    
    if (overrides.secondary != null) {
      lightScheme = lightScheme.copyWith(
        secondary: overrides.secondary,
        onSecondary: _getContrastColor(overrides.secondary!),
      );
      darkScheme = darkScheme.copyWith(
        secondary: overrides.secondary,
        onSecondary: _getContrastColor(overrides.secondary!),
      );
    }
    
    // Create new themes with overrides
    var newLightTheme = SMTheme.light(scheme: lightScheme);
    var newDarkTheme = SMTheme.dark(scheme: darkScheme);
    
    // Apply custom font family if provided
    if (overrides.fontFamily != null) {
      newLightTheme = newLightTheme.copyWith(
        textTheme: newLightTheme.textTheme.apply(fontFamily: overrides.fontFamily),
      );
      newDarkTheme = newDarkTheme.copyWith(
        textTheme: newDarkTheme.textTheme.apply(fontFamily: overrides.fontFamily),
      );
    }
    
    // Apply custom border radius if provided
    if (overrides.borderRadius != null) {
      final radius = BorderRadius.circular(overrides.borderRadius!);
      
      // Update button themes
      newLightTheme = newLightTheme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: newLightTheme.elevatedButtonTheme.style?.copyWith(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: radius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: newLightTheme.outlinedButtonTheme.style?.copyWith(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: radius),
            ),
          ),
        ),
        inputDecorationTheme: newLightTheme.inputDecorationTheme.copyWith(
          border: OutlineInputBorder(borderRadius: radius),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: lightScheme.primary, width: 2),
          ),
        ),
        cardTheme: newLightTheme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      );
      
      // Same for dark theme
      newDarkTheme = newDarkTheme.copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: newDarkTheme.elevatedButtonTheme.style?.copyWith(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: radius),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: newDarkTheme.outlinedButtonTheme.style?.copyWith(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: radius),
            ),
          ),
        ),
        inputDecorationTheme: newDarkTheme.inputDecorationTheme.copyWith(
          border: OutlineInputBorder(borderRadius: radius),
          enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: darkScheme.primary, width: 2),
          ),
        ),
        cardTheme: newDarkTheme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      );
    }
    
    // Apply theme preference
    final mode = overrides.darkPreferred == true ? ThemeMode.dark :
                 overrides.darkPreferred == false ? ThemeMode.light : 
                 state.mode;
    
    state = ThemeState(
      lightTheme: newLightTheme,
      darkTheme: newDarkTheme,
      mode: mode,
      overrides: overrides,
    );
  }
  
  // Calculate contrast color (black or white) based on luminance
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? SMTokens.black : SMTokens.white;
  }
  
  // Load salon theme from API (stub implementation)
  Future<void> loadSalonTheme(String salonId) async {
    try {
      // TODO(ASK): Replace with actual API call
      // final response = await api.get('/v1/salon/$salonId/theme');
      
      // Simulated API response for demo
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Example override data
      final mockData = {
        'primary': '#FFD700',  // Keep gold as default
        'secondary': '#B8860B', // DarkGoldenrod
        'darkPreferred': null,  // Use system preference
        'fontFamily': null,     // Use default
        'borderRadius': null,   // Use default
      };
      
      final overrides = SalonThemeOverrides.fromJson(mockData);
      setSalonOverrides(overrides);
    } catch (e) {
      // Fallback to default theme on error
      debugPrint('Failed to load salon theme: $e');
      setSalonOverrides(null);
    }
  }
  
  // Clear salon overrides and reset to default
  void resetToDefault() {
    setSalonOverrides(null);
  }
}