import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1F2A6D);
  static const Color primaryContainer = Color(0xFFDDE0FF);
  static const Color accent = Color(0xFF3B82FF);
  static const Color accentContainer = Color(0xFFD8E8FF);
  static const Color success = Color(0xFF059669);
  static const Color warning = Color(0xFFDF9B13);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE8EBF7);
  static const Color shadow = Color(0x1F1F2937);
  static const Color nearBlack = Color(0xFF090E1A);

  // Dark-theme surface elevation tiers (Material 3 dark surfaces get
  // progressively lighter, not darker, as they rise above the background) -
  // background is the darkest layer, surface (cards/appbar/sheets) sits a
  // step above it, and surfaceHigh (input fills, highlighted containers) is
  // lighter still. Without this spread, cards were rendered in the exact
  // same color as the scaffold and only readable via drop shadow.
  static const Color darkBackground = Color(0xFF10141F);
  static const Color darkSurface = Color(0xFF1B2236);
  static const Color darkSurfaceHigh = Color(0xFF262F4A);
  static const Color onPrimary = Colors.white;
  static const Color onAccent = Colors.white;
  static const Color onBackground = Color(0xFF101828);
  static const Color onSurface = Color(0xFF101828);
  static const Color onError = Colors.white;

  // Score-band colors used by ScoreRing and anywhere a 0-100 quality score
  // needs a color cue (resume score, completeness, keyword match %).
  static const Color scoreExcellent = Color(0xFF059669);
  static const Color scoreGood = Color(0xFF3B82FF);
  static const Color scoreFair = Color(0xFFDF9B13);
  static const Color scorePoor = Color(0xFFEF4444);

  // Admin branding & accent colors for Admin Access CTA and Console
  static const Color adminPrimary = Color(0xFF4F46E5);
  static const Color adminSecondary = Color(0xFF6366F1);
  static const Color adminBadge = Color(0xFF3730A3);
  static const Color adminGlow = Color(0xFF818CF8);
  static const Color adminContainerLight = Color(0xFFEEF2FF);
  static const Color adminContainerDark = Color(0xFF1E1B4B);

  static Color forScore(num value) {
    if (value >= 80) return scoreExcellent;
    if (value >= 60) return scoreGood;
    if (value >= 40) return scoreFair;
    return scorePoor;
  }
}

