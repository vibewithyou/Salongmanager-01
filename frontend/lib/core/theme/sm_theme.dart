import 'package:flutter/material.dart';
import 'tokens.dart';

class SMTheme {
  // Base Color Schemes (Black/Gold)
  static ColorScheme lightScheme = ColorScheme.fromSeed(
    seedColor: SMTokens.gold,
    brightness: Brightness.light,
    primary: SMTokens.gold,
    onPrimary: SMTokens.black,
    secondary: SMTokens.goldDark,
    onSecondary: SMTokens.black,
    tertiary: SMTokens.black,
    onTertiary: SMTokens.white,
    error: SMTokens.danger,
    onError: SMTokens.white,
    background: SMTokens.white,
    onBackground: SMTokens.black,
    surface: SMTokens.white,
    onSurface: SMTokens.black,
    surfaceVariant: SMTokens.neutral100,
    onSurfaceVariant: SMTokens.neutral700,
    outline: SMTokens.neutral300,
    outlineVariant: SMTokens.neutral200,
    shadow: SMTokens.black,
    scrim: SMTokens.black,
    inverseSurface: SMTokens.neutral900,
    onInverseSurface: SMTokens.white,
    inversePrimary: SMTokens.goldLight,
  );
  
  static ColorScheme darkScheme = ColorScheme.fromSeed(
    seedColor: SMTokens.gold,
    brightness: Brightness.dark,
    primary: SMTokens.gold,
    onPrimary: SMTokens.black,
    secondary: SMTokens.goldLight,
    onSecondary: SMTokens.black,
    tertiary: SMTokens.white,
    onTertiary: SMTokens.black,
    error: SMTokens.danger,
    onError: SMTokens.white,
    background: const Color(0xFF0E0E0E),
    onBackground: SMTokens.white,
    surface: const Color(0xFF1A1A1A),
    onSurface: SMTokens.white,
    surfaceVariant: SMTokens.neutral800,
    onSurfaceVariant: SMTokens.neutral300,
    outline: SMTokens.neutral700,
    outlineVariant: SMTokens.neutral800,
    shadow: SMTokens.black,
    scrim: SMTokens.black,
    inverseSurface: SMTokens.neutral100,
    onInverseSurface: SMTokens.black,
    inversePrimary: SMTokens.goldDark,
  );
  
  static ThemeData light({ColorScheme? scheme}) {
    final cs = scheme ?? lightScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,
      fontFamily: 'Inter', // TODO(ASK: confirm font choice - fallback to system font)
      textTheme: _createTextTheme(Brightness.light),
      appBarTheme: _appBarTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      textButtonTheme: _textButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      iconButtonTheme: _iconButtonTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
      chipTheme: _chipTheme(cs),
      cardTheme: _cardTheme(cs),
      dialogTheme: _dialogTheme(cs),
      bottomSheetTheme: _bottomSheetTheme(cs),
      navigationBarTheme: _navigationBarTheme(cs),
      navigationRailTheme: _navigationRailTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      tooltipTheme: _tooltipTheme(cs),
      dividerTheme: _dividerTheme(cs),
      listTileTheme: _listTileTheme(cs),
      badgeTheme: _badgeTheme(cs),
      progressIndicatorTheme: _progressIndicatorTheme(cs),
      switchTheme: _switchTheme(cs),
      checkboxTheme: _checkboxTheme(cs),
      radioTheme: _radioTheme(cs),
      sliderTheme: _sliderTheme(cs),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      platform: TargetPlatform.iOS, // Consistent across platforms
    );
  }
  
  static ThemeData dark({ColorScheme? scheme}) {
    final cs = scheme ?? darkScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,
      fontFamily: 'Inter',
      textTheme: _createTextTheme(Brightness.dark),
      appBarTheme: _appBarTheme(cs),
      elevatedButtonTheme: _elevatedButtonTheme(cs),
      textButtonTheme: _textButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      iconButtonTheme: _iconButtonTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
      chipTheme: _chipTheme(cs),
      cardTheme: _cardTheme(cs),
      dialogTheme: _dialogTheme(cs),
      bottomSheetTheme: _bottomSheetTheme(cs),
      navigationBarTheme: _navigationBarTheme(cs),
      navigationRailTheme: _navigationRailTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      tooltipTheme: _tooltipTheme(cs),
      dividerTheme: _dividerTheme(cs),
      listTileTheme: _listTileTheme(cs),
      badgeTheme: _badgeTheme(cs),
      progressIndicatorTheme: _progressIndicatorTheme(cs),
      switchTheme: _switchTheme(cs),
      checkboxTheme: _checkboxTheme(cs),
      radioTheme: _radioTheme(cs),
      sliderTheme: _sliderTheme(cs),
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      platform: TargetPlatform.iOS,
    );
  }
  
  static TextTheme _createTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark 
        ? Typography.whiteMountainView 
        : Typography.blackMountainView;
    
    return base.copyWith(
      // Display styles
      displayLarge: base.displayLarge?.copyWith(
        fontSize: SMTokens.text5xl,
        fontWeight: FontWeight.w700,
        letterSpacing: SMTokens.letterSpacingTight,
        height: SMTokens.lineHeightTight,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: SMTokens.text4xl,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingTight,
        height: SMTokens.lineHeightTight,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: SMTokens.text3xl,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightTight,
      ),
      
      // Headline styles
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: SMTokens.text2xl,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightTight,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: SMTokens.textXl,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightTight,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: SMTokens.textLg,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightTight,
      ),
      
      // Title styles
      titleLarge: base.titleLarge?.copyWith(
        fontSize: SMTokens.textLg,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightNormal,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: SMTokens.textBase,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingWide,
        height: SMTokens.lineHeightNormal,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: SMTokens.textSm,
        fontWeight: FontWeight.w600,
        letterSpacing: SMTokens.letterSpacingWide,
        height: SMTokens.lineHeightNormal,
      ),
      
      // Body styles
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: SMTokens.textBase,
        fontWeight: FontWeight.w400,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightNormal,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: SMTokens.textSm,
        fontWeight: FontWeight.w400,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightNormal,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: SMTokens.textXs,
        fontWeight: FontWeight.w400,
        letterSpacing: SMTokens.letterSpacingNormal,
        height: SMTokens.lineHeightNormal,
      ),
      
      // Label styles
      labelLarge: base.labelLarge?.copyWith(
        fontSize: SMTokens.textSm,
        fontWeight: FontWeight.w500,
        letterSpacing: SMTokens.letterSpacingWide,
        height: SMTokens.lineHeightNormal,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: SMTokens.textXs,
        fontWeight: FontWeight.w500,
        letterSpacing: SMTokens.letterSpacingWider,
        height: SMTokens.lineHeightNormal,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: SMTokens.letterSpacingWidest,
        height: SMTokens.lineHeightNormal,
      ),
    );
  }
  
  static AppBarTheme _appBarTheme(ColorScheme cs) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: SMTokens.textLg,
        fontWeight: FontWeight.w600,
        color: cs.onSurface,
      ),
    );
  }
  
  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme cs) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: SMTokens.s6, vertical: SMTokens.s3),
        minimumSize: const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
        disabledForegroundColor: cs.onSurface.withOpacity(0.38),
        textStyle: const TextStyle(
          fontSize: SMTokens.textSm,
          fontWeight: FontWeight.w600,
          letterSpacing: SMTokens.letterSpacingWide,
        ),
      ),
    );
  }
  
  static TextButtonThemeData _textButtonTheme(ColorScheme cs) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SMTokens.s4, vertical: SMTokens.s2),
        minimumSize: const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        foregroundColor: cs.primary,
        textStyle: const TextStyle(
          fontSize: SMTokens.textSm,
          fontWeight: FontWeight.w600,
          letterSpacing: SMTokens.letterSpacingWide,
        ),
      ),
    );
  }
  
  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SMTokens.s6, vertical: SMTokens.s3),
        minimumSize: const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        side: BorderSide(color: cs.outline),
        foregroundColor: cs.onSurface,
        textStyle: const TextStyle(
          fontSize: SMTokens.textSm,
          fontWeight: FontWeight.w600,
          letterSpacing: SMTokens.letterSpacingWide,
        ),
      ),
    );
  }
  
  static IconButtonThemeData _iconButtonTheme(ColorScheme cs) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
        padding: const EdgeInsets.all(SMTokens.s2),
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
      ),
    );
  }
  
  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SMTokens.s6, vertical: SMTokens.s3),
        minimumSize: const Size(SMTokens.touchTargetMin, SMTokens.touchTargetMin),
        shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
        textStyle: const TextStyle(
          fontSize: SMTokens.textSm,
          fontWeight: FontWeight.w600,
          letterSpacing: SMTokens.letterSpacingWide,
        ),
      ),
    );
  }
  
  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) {
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: SMTokens.s4, vertical: SMTokens.s3),
      border: OutlineInputBorder(
        borderRadius: SMTokens.rMd,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: SMTokens.rMd,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: SMTokens.rMd,
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: SMTokens.rMd,
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: SMTokens.rMd,
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: SMTokens.textSm,
        color: cs.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        fontSize: SMTokens.textSm,
        color: cs.onSurfaceVariant.withOpacity(0.6),
      ),
      errorStyle: TextStyle(
        fontSize: SMTokens.textXs,
        color: cs.error,
      ),
    );
  }
  
  static ChipThemeData _chipTheme(ColorScheme cs) {
    return ChipThemeData(
      shape: const StadiumBorder(),
      backgroundColor: cs.surfaceVariant,
      deleteIconColor: cs.onSurfaceVariant,
      disabledColor: cs.onSurface.withOpacity(0.12),
      selectedColor: cs.primary.withOpacity(0.15),
      secondarySelectedColor: cs.secondary.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: SMTokens.s3, vertical: SMTokens.s1),
      labelPadding: const EdgeInsets.symmetric(horizontal: SMTokens.s2),
      labelStyle: TextStyle(
        fontSize: SMTokens.textSm,
        color: cs.onSurfaceVariant,
      ),
      secondaryLabelStyle: TextStyle(
        fontSize: SMTokens.textSm,
        color: cs.onSurface,
      ),
      brightness: cs.brightness,
    );
  }
  
  static CardTheme _cardTheme(ColorScheme cs) {
    return CardTheme(
      elevation: 0,
      margin: const EdgeInsets.all(SMTokens.s2),
      shape: RoundedRectangleBorder(borderRadius: SMTokens.rLg),
      color: cs.surface,
    );
  }
  
  static DialogTheme _dialogTheme(ColorScheme cs) {
    return DialogTheme(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: SMTokens.rXl),
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
    );
  }
  
  static BottomSheetTheme _bottomSheetTheme(ColorScheme cs) {
    return BottomSheetTheme(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SMTokens.s5)),
      ),
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: cs.onSurfaceVariant.withOpacity(0.4),
      dragHandleSize: const Size(48, 4),
    );
  }
  
  static NavigationBarThemeData _navigationBarTheme(ColorScheme cs) {
    return NavigationBarThemeData(
      elevation: 0,
      height: 80,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: cs.primary.withOpacity(0.15),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: SMTokens.textXs,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
  
  static NavigationRailThemeData _navigationRailTheme(ColorScheme cs) {
    return NavigationRailThemeData(
      elevation: 0,
      backgroundColor: cs.surface,
      selectedIconTheme: IconThemeData(color: cs.primary),
      unselectedIconTheme: IconThemeData(color: cs.onSurfaceVariant),
      indicatorColor: cs.primary.withOpacity(0.15),
      labelType: NavigationRailLabelType.all,
      selectedLabelTextStyle: TextStyle(
        fontSize: SMTokens.textXs,
        fontWeight: FontWeight.w600,
        color: cs.primary,
      ),
      unselectedLabelTextStyle: TextStyle(
        fontSize: SMTokens.textXs,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
      ),
    );
  }
  
  static SnackBarThemeData _snackBarTheme(ColorScheme cs) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
      backgroundColor: cs.inverseSurface,
      contentTextStyle: TextStyle(
        fontSize: SMTokens.textSm,
        color: cs.onInverseSurface,
      ),
      actionTextColor: cs.inversePrimary,
    );
  }
  
  static TooltipThemeData _tooltipTheme(ColorScheme cs) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: cs.inverseSurface,
        borderRadius: SMTokens.rSm,
      ),
      textStyle: TextStyle(
        fontSize: SMTokens.textXs,
        color: cs.onInverseSurface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: SMTokens.s3, vertical: SMTokens.s2),
      margin: const EdgeInsets.all(SMTokens.s2),
    );
  }
  
  static DividerThemeData _dividerTheme(ColorScheme cs) {
    return DividerThemeData(
      color: cs.outlineVariant,
      thickness: 1,
      space: SMTokens.s4,
    );
  }
  
  static ListTileThemeData _listTileTheme(ColorScheme cs) {
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: SMTokens.s4),
      minVerticalPadding: SMTokens.s2,
      shape: RoundedRectangleBorder(borderRadius: SMTokens.rMd),
      tileColor: Colors.transparent,
      selectedTileColor: cs.primary.withOpacity(0.08),
      textColor: cs.onSurface,
      iconColor: cs.onSurfaceVariant,
      selectedColor: cs.primary,
    );
  }
  
  static BadgeThemeData _badgeTheme(ColorScheme cs) {
    return BadgeThemeData(
      backgroundColor: cs.error,
      textColor: cs.onError,
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  static ProgressIndicatorThemeData _progressIndicatorTheme(ColorScheme cs) {
    return ProgressIndicatorThemeData(
      color: cs.primary,
      linearTrackColor: cs.primary.withOpacity(0.2),
      circularTrackColor: cs.primary.withOpacity(0.2),
    );
  }
  
  static SwitchThemeData _switchTheme(ColorScheme cs) {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return cs.primary;
        }
        return cs.outline;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return cs.primary.withOpacity(0.5);
        }
        return cs.surfaceVariant;
      }),
    );
  }
  
  static CheckboxThemeData _checkboxTheme(ColorScheme cs) {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return cs.primary;
        }
        return null;
      }),
      checkColor: MaterialStateProperty.all(cs.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: SMTokens.rXs),
    );
  }
  
  static RadioThemeData _radioTheme(ColorScheme cs) {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return cs.primary;
        }
        return cs.onSurfaceVariant;
      }),
    );
  }
  
  static SliderThemeData _sliderTheme(ColorScheme cs) {
    return SliderThemeData(
      activeTrackColor: cs.primary,
      inactiveTrackColor: cs.primary.withOpacity(0.2),
      thumbColor: cs.primary,
      overlayColor: cs.primary.withOpacity(0.1),
      valueIndicatorColor: cs.primary,
      valueIndicatorTextStyle: TextStyle(
        color: cs.onPrimary,
        fontSize: SMTokens.textSm,
      ),
    );
  }
}