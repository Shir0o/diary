@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/info_screen.dart';
import 'package:diary/config/app_theme.dart';

void main() {
  group('InfoScreen Golden Tests', () {
    testGoldens('HelpScreen - light theme appearance', (tester) async {
      await tester.pumpWidgetBuilder(
        InfoScreen.help(onBackPressed: () {}),
        wrapper: (child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: child,
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'help_screen_light');
    });

    testGoldens('HelpScreen - dark theme appearance', (tester) async {
      await tester.pumpWidgetBuilder(
        InfoScreen.help(onBackPressed: () {}),
        wrapper: (child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: child,
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'help_screen_dark');
    });

    testGoldens('AboutScreen - light theme appearance', (tester) async {
      await tester.pumpWidgetBuilder(
        InfoScreen.about(onBackPressed: () {}),
        wrapper: (child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: child,
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'about_screen_light');
    });

    testGoldens('AboutScreen - dark theme appearance', (tester) async {
      await tester.pumpWidgetBuilder(
        InfoScreen.about(onBackPressed: () {}),
        wrapper: (child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: child,
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'about_screen_dark');
    });
  });
}
