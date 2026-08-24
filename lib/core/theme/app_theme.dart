import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

class AppTheme {
  AppTheme._();

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    surface: const Color(0xFFFBFCFF),
    onSurface: AppColors.onSurface,
    surfaceTint: AppColors.surface,
    surfaceContainerHighest: const Color(0xFFEFF2F9),
    onSurfaceVariant: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onError,
    primaryContainer: AppColors.primaryContainer,
    secondaryContainer: AppColors.accentContainer,
    outline: AppColors.primary.withAlpha((0.32 * 255).round()),
    shadow: AppColors.shadow,
    inverseSurface: AppColors.nearBlack,
    inversePrimary: AppColors.accent,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.primary,
    onSecondary: AppColors.onPrimary,
    surface: AppColors.darkSurface,
    onSurface: AppColors.onPrimary,
    surfaceTint: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.darkSurfaceHigh,
    onSurfaceVariant: AppColors.onPrimary,
    error: AppColors.error,
    onError: AppColors.onError,
    primaryContainer: const Color(0xFF2C3C82),
    secondaryContainer: const Color(0xFF121B31),
    outline: const Color(0xFF6B7280),
    shadow: Colors.black,
    inverseSurface: AppColors.surface,
    inversePrimary: AppColors.primary,
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: _lightColorScheme.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightColorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _lightColorScheme.outline.withAlpha((0.2 * 255).round())),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _lightColorScheme.outline.withAlpha((0.18 * 255).round())),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _lightColorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _lightColorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: _lightColorScheme.onSurface.withAlpha((0.8 * 255).round())),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      Typography.material2021(platform: TargetPlatform.android).black,
    ).apply(bodyColor: _lightColorScheme.onSurface, displayColor: _lightColorScheme.onSurface).copyWith(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _lightColorScheme.onSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _lightColorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _lightColorScheme.onSurface),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _lightColorScheme.onSurface.withAlpha((0.9 * 255).round())),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightColorScheme.primary,
        foregroundColor: _lightColorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightColorScheme.onSurface,
        side: BorderSide(color: _lightColorScheme.outline.withAlpha((0.4 * 255).round())),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
      elevation: 10,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightColorScheme.surface,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _lightColorScheme.surface,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightColorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      labelStyle: TextStyle(color: _lightColorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _lightColorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: _lightColorScheme.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.outline.withAlpha((0.16 * 255).round()),
      thickness: 1,
      space: 32,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _lightColorScheme.primary,
      circularTrackColor: _lightColorScheme.primary.withAlpha((0.14 * 255).round()),
      linearTrackColor: _lightColorScheme.primary.withAlpha((0.14 * 255).round()),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: _lightColorScheme.surface,
      indicatorColor: _lightColorScheme.primary.withAlpha((0.12 * 255).round()),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? _lightColorScheme.primary : _lightColorScheme.onSurface.withAlpha((0.6 * 255).round()),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? _lightColorScheme.primary : _lightColorScheme.onSurface.withAlpha((0.6 * 255).round()),
        );
      }),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: _darkColorScheme.surface,
      elevation: 0,
      shadowColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: Colors.white.withAlpha((0.06 * 255).round())),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkColorScheme.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _darkColorScheme.outline.withAlpha((0.22 * 255).round())),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _darkColorScheme.outline.withAlpha((0.18 * 255).round())),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _darkColorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: _darkColorScheme.error, width: 2),
      ),
      labelStyle: TextStyle(color: _darkColorScheme.onSurface.withAlpha((0.8 * 255).round())),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      Typography.material2021(platform: TargetPlatform.android).white,
    ).apply(bodyColor: _darkColorScheme.onSurface, displayColor: _darkColorScheme.onSurface).copyWith(
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _darkColorScheme.onSurface),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _darkColorScheme.onSurface),
      bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: _darkColorScheme.onSurface),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _darkColorScheme.onSurface.withAlpha((0.9 * 255).round())),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColorScheme.primary,
        foregroundColor: _darkColorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkColorScheme.onSurface,
        side: BorderSide(color: _darkColorScheme.outline.withAlpha((0.4 * 255).round())),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
      elevation: 10,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkColorScheme.surface,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: _darkColorScheme.surface,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _darkColorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      labelStyle: TextStyle(color: _darkColorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 12.5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkColorScheme.inverseSurface,
      contentTextStyle: const TextStyle(color: AppColors.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      elevation: 6,
    ),
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.outline.withAlpha((0.2 * 255).round()),
      thickness: 1,
      space: 32,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _darkColorScheme.primary,
      circularTrackColor: _darkColorScheme.primary.withAlpha((0.18 * 255).round()),
      linearTrackColor: _darkColorScheme.primary.withAlpha((0.18 * 255).round()),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 64,
      backgroundColor: _darkColorScheme.surface,
      indicatorColor: _darkColorScheme.primary.withAlpha((0.18 * 255).round()),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? _darkColorScheme.primary : _darkColorScheme.onSurface.withAlpha((0.6 * 255).round()),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: selected ? _darkColorScheme.primary : _darkColorScheme.onSurface.withAlpha((0.6 * 255).round()),
        );
      }),
    ),
  );
}
