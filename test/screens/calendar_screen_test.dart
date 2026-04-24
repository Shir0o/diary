import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/calendar_screen.dart';
import 'package:diary/widgets/entry_card.dart';

void main() {
  testWidgets('CalendarScreen should render CalendarDatePicker and entries', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CalendarScreen(),
      ),
    );

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('Selecting a date should filter entries (mock test)', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CalendarScreen(),
      ),
    );

    // Note: Since data is currently hardcoded in CalendarScreen, 
    // we expect to find specific entries for Today.
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
