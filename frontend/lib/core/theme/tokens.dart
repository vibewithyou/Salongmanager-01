import 'package:flutter/material.dart';

/// Global Design Tokens for SalonManager
/// Based on a Black/Gold color scheme with semantic tokens for states
class SMTokens {
  // Primary Brand Colors (Schwarz/Gold)
  static const Color black = Color(0xFF000000);
  static const Color gold = Color(0xFFFFD700);
  static const Color white = Color(0xFFFFFFFF);
  
  // Gold variations for better contrast
  static const Color goldLight = Color(0xFFFFE234);
  static const Color goldDark = Color(0xFFD4AF37);
  
  // Semantic Colors
  static const Color success = Color(0xFF1DB954);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFDC2626);
  static const Color info = Color(0xFF2563EB);
  
  // Neutral Scale
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  
  // Spacing Scale (4px base)
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double s20 = 80;
  static const double s24 = 96;
  
  // Border Radius
  static const BorderRadius rXs = BorderRadius.all(Radius.circular(4));
  static const BorderRadius rSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius rMd = BorderRadius.all(Radius.circular(12));
  static const BorderRadius rLg = BorderRadius.all(Radius.circular(16));
  static const BorderRadius rXl = BorderRadius.all(Radius.circular(20));
  static const BorderRadius rFull = BorderRadius.all(Radius.circular(999));
  
  // Elevation & Shadows
  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Color(0x25000000),
      blurRadius: 48,
      offset: Offset(0, 16),
    ),
  ];
  
  // Typography Scale
  static const double textXs = 12;
  static const double textSm = 14;
  static const double textBase = 16;
  static const double textLg = 18;
  static const double textXl = 20;
  static const double text2xl = 24;
  static const double text3xl = 28;
  static const double text4xl = 32;
  static const double text5xl = 36;
  
  // Line Heights
  static const double lineHeightTight = 1.25;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  
  // Letter Spacing
  static const double letterSpacingTighter = -0.05;
  static const double letterSpacingTight = -0.025;
  static const double letterSpacingNormal = 0;
  static const double letterSpacingWide = 0.025;
  static const double letterSpacingWider = 0.05;
  static const double letterSpacingWidest = 0.1;
  
  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // Responsive Breakpoints
  static const double breakpointSm = 600;
  static const double breakpointMd = 1024;
  static const double breakpointLg = 1440;
  static const double breakpointXl = 1920;
  
  // Touch Target Size (A11y)
  static const double touchTargetMin = 48;
}