import 'package:flutter/material.dart';

/// Warm Minimalist Color Palette for HomeGuardian
/// Specified in project requirements:
/// - Background: #F8F3EC (Warm Cream)
/// - Sand: #E9D8C8
/// - Terracotta: #B96F50
/// - Brown: #87513D
/// - Dark Brown: #47352D
/// - White: #FFFFFF
class AppColors {
  AppColors._();

  // Core Theme Palette
  static const Color background = Color(0xFFF8F3EC); // Warm Cream
  static const Color sand = Color(0xFFE9D8C8);       // Soft Sand accent / borders
  static const Color terracotta = Color(0xFFB96F50); // Primary Action / Highlights
  static const Color brown = Color(0xFF87513D);      // Secondary / Accents
  static const Color darkBrown = Color(0xFF47352D);  // High-contrast Headings / Text
  static const Color white = Color(0xFFFFFFFF);      // Card surfaces

  // Supporting Functional Accents
  static const Color textPrimary = Color(0xFF2C221E);
  static const Color textSecondary = Color(0xFF756357);
  static const Color textMuted = Color(0xFFA8998D);

  static const Color success = Color(0xFF4E7D5B);
  static const Color warning = Color(0xFFD98A3A);
  static const Color error = Color(0xFFB54538);
  static const Color info = Color(0xFF53738A);

  // Surface and Border Variations
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF3ECE1);
  static const Color borderLight = Color(0xFFE5D5C4);
}

