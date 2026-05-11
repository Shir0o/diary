import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/analytics_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  group('AnalyticsScreen Golden Tests', () {
    final mockEntries = [
      DiaryEntry(
        id: '1',
        date: DateTime(2026, 4, 24),
        title: 'T1',
        content: 'C1',
        mood: '🚀',
      ),
      DiaryEntry(
        id: '2',
        date: DateTime(2026, 4, 23),
        title: 'T2',
        content: 'C2',
        mood: '🚀',
      ),
      DiaryEntry(
        id: '3',
        date: DateTime(2026, 4, 22),
        title: 'T3',
        content: 'C3',
        mood: '☕',
      ),
      DiaryEntry(
        id: '4',
        date: DateTime(2026, 4, 20),
        title: 'T4',
        content: 'C4',
        mood: '📝',
      ),
    ];

    testGoldens('AnalyticsScreen - appearance', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
        AnalyticsScreen(
          entries: mockEntries,
          referenceDate: DateTime(2026, 4, 24),
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'analytics_screen_appearance');
    });
  });
}
