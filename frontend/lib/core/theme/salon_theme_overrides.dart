import 'package:flutter/material.dart';

/// Salon-specific theme overrides loaded from API
/// Each salon can customize primary/secondary colors and theme preference
class SalonThemeOverrides {
  final Color? primary;
  final Color? secondary;
  final bool? darkPreferred;
  final String? fontFamily;
  final double? borderRadius;
  
  const SalonThemeOverrides({
    this.primary,
    this.secondary,
    this.darkPreferred,
    this.fontFamily,
    this.borderRadius,
  });
  
  factory SalonThemeOverrides.fromJson(Map<String, dynamic> json) {
    Color? parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return null;
      
      // Support both #RRGGBB and RRGGBB formats
      final cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length != 6) return null;
      
      try {
        return Color(int.parse('0xff$cleanHex'));
      } catch (e) {
        return null;
      }
    }
    
    double? parseRadius(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }
    
    return SalonThemeOverrides(
      primary: parseColor(json['primary'] as String?),
      secondary: parseColor(json['secondary'] as String?),
      darkPreferred: json['darkPreferred'] as bool?,
      fontFamily: json['fontFamily'] as String?,
      borderRadius: parseRadius(json['borderRadius']),
    );
  }
  
  Map<String, dynamic> toJson() => {
    if (primary != null) 'primary': '#${primary!.value.toRadixString(16).substring(2).toUpperCase()}',
    if (secondary != null) 'secondary': '#${secondary!.value.toRadixString(16).substring(2).toUpperCase()}',
    if (darkPreferred != null) 'darkPreferred': darkPreferred,
    if (fontFamily != null) 'fontFamily': fontFamily,
    if (borderRadius != null) 'borderRadius': borderRadius,
  };
  
  SalonThemeOverrides copyWith({
    Color? primary,
    Color? secondary,
    bool? darkPreferred,
    String? fontFamily,
    double? borderRadius,
  }) {
    return SalonThemeOverrides(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      darkPreferred: darkPreferred ?? this.darkPreferred,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SalonThemeOverrides &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.darkPreferred == darkPreferred &&
        other.fontFamily == fontFamily &&
        other.borderRadius == borderRadius;
  }
  
  @override
  int get hashCode => Object.hash(
    primary,
    secondary,
    darkPreferred,
    fontFamily,
    borderRadius,
  );
}