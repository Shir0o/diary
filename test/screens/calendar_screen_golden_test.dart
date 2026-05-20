@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/calendar_screen.dart';

void main() {
  testGoldens('CalendarScreen - appearance', (tester) async {
    final testDate = DateTime(2026, 4, 24);
    await tester.pumpWidgetBuilder(
      CalendarScreen(initialDate: testDate, onBackPressed: () {}),
      wrapper: (child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6751a4)),
          useMaterial3: true,
        ),
        home: child,
      ),
      surfaceSize: const Size(390, 844),
    );

    await screenMatchesGolden(tester, 'calendar_screen_appearance');
  });
}
