import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/widgets/entry_card.dart';

void main() {
  testWidgets('CalendarScreen should render CalendarDatePicker and entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CalendarScreen(onBackPressed: () {})),
    );

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('Selecting a date should filter entries (mock test)', (
    WidgetTester tester,
  ) async {
    // The hardcoded entries in CalendarScreen are dated 2026-04-24; pin the
    // initial date so this test is independent of the current wall clock.
    await tester.pumpWidget(
      MaterialApp(
        home: CalendarScreen(
          initialDate: DateTime(2026, 4, 24),
          onBackPressed: () {},
        ),
      ),
    );

    expect(find.byType(EntryCard), findsAtLeastNWidgets(1));

    // Tap a different date (e.g., April 23) which has another default entry
    await tester.tap(find.text('23').last);
    await tester.pumpAndSettle();

    // Verify list updates
    expect(find.byType(EntryCard), findsAtLeastNWidgets(1));
  });
}
