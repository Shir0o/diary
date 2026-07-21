import 'package:flutter/material.dart';
import '../helpers/font_helper.dart';

class AppTheme {
  AppTheme._();

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

  // Opacity levels
  static const double opacityHint = 0.4;
  static const double opacitySubtle = 0.5;
  static const double opacityMedium = 0.6;

  // Font Sizes
  static const double fontSizeCaption = 12.0;
  static const double fontSizeBodySmall = 13.0;
  static const double fontSizeBodyMedium = 14.0;
  static const double fontSizeTitleMedium = 18.0;

  // Icon and Indicator Sizes
  static const double iconSizeSmall = 18.0;
  static const double progressIndicatorSizeMedium = 24.0;
  static const double progressIndicatorSizeSmall = 18.0;
  static const double progressIndicatorStrokeWidthMedium = 2.5;
  static const double progressIndicatorStrokeWidthSmall = 2.0;

  // Location/Sheet Layout Dimensions
  static const double locationSheetSuggestionsHeight = 180.0;

  // Animation durations
  static const Duration transitionDuration = Duration(milliseconds: 350);
  static const Duration reverseTransitionDuration = Duration(milliseconds: 250);
  static const Duration dictationRestartDelay = Duration(milliseconds: 300);

  // Animation scale & offset values
  static const double scaleRouteTransition = 0.90;
  static const double scaleSwitcherTransition = 0.96;
  static const double parallaxSlideOffset = -0.3;

  // Palette details
  static Color getPrimaryColor(String palette) {
    switch (palette) {
      case 'rose':
        return const Color(0xFFE589A6);
      case 'sky':
        return const Color(0xFF6CA8FF);
      case 'sage':
        return const Color(0xFF7BB98A);
      case 'lilac':
      default:
        return const Color(0xFF8B6CFF);
    }
  }

  static Color getSecondaryColor(String palette) {
    switch (palette) {
      case 'rose':
        return const Color(0xFFF0B6A0);
      case 'sky':
        return const Color(0xFF8BD0E0);
      case 'sage':
        return const Color(0xFFC3D98E);
      case 'lilac':
      default:
        return const Color(0xFFB06CA6);
    }
  }

  static Gradient getAccentGradient(String palette) {
    return LinearGradient(
      colors: [getPrimaryColor(palette), getSecondaryColor(palette)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static Gradient getScreenBackground(Brightness brightness, String palette) {
    if (brightness == Brightness.light) {
      switch (palette) {
        case 'rose':
          return const LinearGradient(
            colors: [Color(0xFFFFF1F4), Color(0xFFFAF3F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'sky':
          return const LinearGradient(
            colors: [Color(0xFFF1F7FF), Color(0xFFF3FAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'sage':
          return const LinearGradient(
            colors: [Color(0xFFF1FFF4), Color(0xFFFAF9F3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'lilac':
        default:
          return const LinearGradient(
            colors: [Color(0xFFF4F1FF), Color(0xFFF7F3FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
      }
    } else {
      switch (palette) {
        case 'rose':
          return const LinearGradient(
            colors: [Color(0xFF301820), Color(0xFF221116)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'sky':
          return const LinearGradient(
            colors: [Color(0xFF182530), Color(0xFF111A22)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'sage':
          return const LinearGradient(
            colors: [Color(0xFF183021), Color(0xFF112217)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
        case 'lilac':
        default:
          return const LinearGradient(
            colors: [Color(0xFF1D1830), Color(0xFF151122)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );
      }
    }
  }

  static Color getCardBackground(Brightness brightness, String palette) {
    if (brightness == Brightness.light) {
      return Colors.white;
    } else {
      switch (palette) {
        case 'rose':
          return const Color(0xFF392128);
        case 'sky':
          return const Color(0xFF212C39);
        case 'sage':
          return const Color(0xFF21392B);
        case 'lilac':
        default:
          return const Color(0xFF282139);
      }
    }
  }

  static Color getCardBackground2(Brightness brightness, String palette) {
    if (brightness == Brightness.light) {
      switch (palette) {
        case 'rose':
          return const Color(0xFFFAF3F5);
        case 'sky':
          return const Color(0xFFF3FAF9);
        case 'sage':
          return const Color(0xFFFAF9F3);
        case 'lilac':
        default:
          return const Color(0xFFFAF8FD);
      }
    } else {
      switch (palette) {
        case 'rose':
          return const Color(0xFF2C191E);
        case 'sky':
          return const Color(0xFF19222C);
        case 'sage':
          return const Color(0xFF192C21);
        case 'lilac':
        default:
          return const Color(0xFF221B32);
      }
    }
  }

  static Color getHeadingColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFF3A3357)
        : const Color(0xFFEFEAF7);
  }

  static Color getBodyColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFF7D769A)
        : const Color(0xFFB8B0D2);
  }

  static Color getMutedColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFF8B83A8)
        : const Color(0xFF9A92B8);
  }

  static Color getFaintColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFA99FC4)
        : const Color(0xFF7C749A);
  }

  static Color getHairlineColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFF1EDF8)
        : Colors.white.withValues(alpha: 0.08);
  }

  static Color getDottedLineColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFD9CDF5)
        : Colors.white.withValues(alpha: 0.16);
  }

  static Color getSoftBg(String palette) {
    switch (palette) {
      case 'rose':
        return const Color(0xFFFDEBF0);
      case 'sky':
        return const Color(0xFFEBF4FF);
      case 'sage':
        return const Color(0xFFECF5ED);
      case 'lilac':
      default:
        return const Color(0xFFEFE9FF);
    }
  }

  static Color getChipColor(Brightness brightness) {
    return brightness == Brightness.light
        ? const Color(0xFFF4F1FB)
        : Colors.white.withValues(alpha: 0.06);
  }

  static ThemeData buildTheme(Brightness brightness, String palette) {
    final primary = getPrimaryColor(palette);
    final background = getScreenBackground(brightness, palette).colors.first;
    final cardBg = getCardBackground(brightness, palette);
    final heading = getHeadingColor(brightness);
    final body = getBodyColor(brightness);
    final muted = getMutedColor(brightness);
    final outlineColor = getHairlineColor(brightness);

    final fontName = 'Quicksand';

    final textTheme = TextTheme(
      headlineLarge: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      headlineSmall: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      titleLarge: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      titleMedium: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: safeGoogleFont(
        fontName,
        color: body,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: safeGoogleFont(
        fontName,
        color: body,
        fontSize: 14,
        height: 1.45,
      ),
      bodySmall: safeGoogleFont(fontName, color: muted, fontSize: 12),
      labelLarge: safeGoogleFont(
        fontName,
        color: heading,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      labelMedium: safeGoogleFont(fontName, color: muted, fontSize: 12),
      labelSmall: safeGoogleFont(fontName, color: muted, fontSize: 10),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        surface: cardBg,
        onSurface: heading,
        outline: outlineColor,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: heading),
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 20),
      ),
      dividerColor: outlineColor,
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: outlineColor),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => buildTheme(Brightness.light, 'lilac');
  static ThemeData get darkTheme => buildTheme(Brightness.dark, 'lilac');
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
