@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/new_entry_screen.dart';

void main() {
  testGoldens('NewEntryScreen - appearance', (tester) async {
    await tester.pumpWidgetBuilder(
      NewEntryScreen(initialDate: DateTime(2026, 4, 24, 10, 30)),
      wrapper: (child) =>
          MaterialApp(debugShowCheckedModeBanner: false, home: child),
      surfaceSize: const Size(390, 844), // iPhone 13/14 size
    );

    await screenMatchesGolden(tester, 'new_entry_screen_appearance');
  });
}
