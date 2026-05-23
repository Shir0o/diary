import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/analytics_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final entries = [
    DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Project Launch',
      content: 'Launching our brand new flutter diary application.',
      mood: '🚀',
    ),
  ];

  testWidgets('AnalyticsScreen renders range chips and responds to selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AnalyticsScreen(entries: entries, onBackPressed: () {}),
      ),
    );

    // Verify chips render
    expect(find.text('7 Days'), findsOneWidget);
    expect(find.text('30 Days'), findsOneWidget);
    expect(find.text('90 Days'), findsOneWidget);
    expect(find.text('All Time'), findsOneWidget);

    // Tap '7 Days'
    await tester.tap(find.text('7 Days'));
    await tester.pumpAndSettle();

    // Verify dynamic calculations update
    expect(find.text('Total Entries'), findsOneWidget);
  });
}
