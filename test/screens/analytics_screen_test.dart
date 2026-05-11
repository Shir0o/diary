import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/analytics_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
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
  ];

  testWidgets('AnalyticsScreen renders correctly with data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalyticsScreen(
          entries: mockEntries,
          referenceDate: DateTime(2026, 4, 24),
        ),
      ),
    );

    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Total Entries'), findsOneWidget);
    expect(find.text('3'), findsOneWidget); // Total count
    expect(find.text('Current Streak'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget); // Streak
    expect(find.text('Mood Distribution'), findsOneWidget);
    expect(find.text('🚀'), findsOneWidget);
    expect(find.text('☕'), findsOneWidget);
  });

  testWidgets('AnalyticsScreen handles empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: AnalyticsScreen(entries: [])),
    );

    expect(find.text('0'), findsOneWidget);
    expect(find.text('0 days'), findsOneWidget);
    expect(find.text('No data available'), findsOneWidget);
  });
}
