import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand
  static const Color primaryColor = Color(0xFF6751a4);

  // Light palette
  static const Color lightBackground = Color(0xFFFEF7FF);
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Color(0xFF141316);
  static const Color lightOutline = Color(0xFFCAC4D0);
  static const Color lightIconBg = Color(0xFFF2F1F3);

  // Dark palette
  static const Color darkBackground = Color(0xFF141316);
  static const Color darkSurface = Color(0xFF1F1D22);
  static const Color darkOnSurface = Color(0xFFE6E1E9);
  static const Color darkOutline = Color(0xFF49454F);
  static const Color darkIconBg = Color(0xFF2A282E);

  // Spacing
  static const double spacingExtraSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: lightSurface,
      onSurface: lightOnSurface,
      outline: lightOutline,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: lightBackground.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: lightOnSurface),
      titleTextStyle: const TextStyle(
        color: lightOnSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'IBM Plex Sans',
      ),
    ),
    dividerColor: lightOutline.withValues(alpha: 0.3),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      surface: darkSurface,
      onSurface: darkOnSurface,
      outline: darkOutline,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: darkOnSurface),
      titleTextStyle: const TextStyle(
        color: darkOnSurface,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'IBM Plex Sans',
      ),
    ),
    dividerColor: darkOutline.withValues(alpha: 0.4),
  );
}

enum ThemeModeOption {
  system('System Default', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  final String label;
  final ThemeMode mode;

  const ThemeModeOption(this.label, this.mode);

  static ThemeModeOption fromMode(ThemeMode mode) {
    return ThemeModeOption.values.firstWhere((e) => e.mode == mode);
  }

  static ThemeModeOption fromLabel(String label) {
    return ThemeModeOption.values.firstWhere(
      (e) => e.label == label,
      orElse: () => ThemeModeOption.system,
    );
  }
}
