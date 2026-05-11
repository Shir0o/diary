@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/settings_screen.dart';

void main() {
  testGoldens('SettingsScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      const SettingsScreen(),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'settings_screen_appearance');
  });
}
