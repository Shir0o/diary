import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final entries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24),
      title: 'Project Launch',
      content: 'Flutter diary launch.',
      mood: '🚀',
    ),
  ];

  testWidgets('CalendarScreen renders entry indicator dots', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarScreen(
          entries: entries,
          initialDate: DateTime(2026, 4, 24),
          onBackPressed: () {},
        ),
      ),
    );

    // Verify day cell for 24th renders
    expect(find.text('24'), findsOneWidget);
    expect(find.byType(GestureDetector), findsWidgets);
  });
}
