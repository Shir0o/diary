import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/timeline_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final mockEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'T1',
      content: 'C1',
      mood: '🚀',
    ),
  ];

  testWidgets('TimelineScreen should render entries and FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: TimelineScreen(entries: mockEntries)),
    );

    expect(find.text('Diary'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Initially should show our mock entries
    expect(find.text('Today'), findsOneWidget);
  });
}
