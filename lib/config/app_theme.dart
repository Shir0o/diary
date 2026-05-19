import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryColor = Color(0xFF6751a4);
  static const Color onPrimaryColor = Colors.white;
  static const Color backgroundColor = Color(0xFFFEF7FF);
  static const Color surfaceColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF141316);
  static const Color outlineColor = Color(0xFFCAC4D0);

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
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
      background: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: onSurfaceColor),
      titleTextStyle: const TextStyle(
        color: onSurfaceColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'IBM Plex Sans',
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'IBM Plex Sans',
      ),
    ),
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
