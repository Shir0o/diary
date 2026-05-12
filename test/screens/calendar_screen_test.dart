import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/widgets/entry_card.dart';
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
  ];

  testWidgets('CalendarScreen should render CalendarDatePicker and entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CalendarScreen(entries: mockEntries)),
    );

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('Selecting a date should filter entries (mock test)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarScreen(
          initialDate: DateTime(2026, 4, 24),
          entries: mockEntries,
        ),
      ),
    );

    expect(find.byType(EntryCard), findsAtLeastNWidgets(1));

    // Tap a different date (e.g., yesterday)
    // Finding a date in CalendarDatePicker is tricky by text if it's not unique,
    // but usually we can find the day number.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await tester.tap(find.text(yesterday.day.toString()).last);
    await tester.pumpAndSettle();

    // Verify list updates (this depends on implementation)
    // For now this is just a placeholder test structure.
  });
}
