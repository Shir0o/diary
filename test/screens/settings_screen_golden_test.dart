@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:diary/screens/settings_screen.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/theme_provider.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  testGoldens('SettingsScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => DiaryProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const SettingsScreen(),
      ),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'settings_screen_appearance');
  });
}
