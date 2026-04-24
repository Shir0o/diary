import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/widgets/entry_card.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  testWidgets('EntryCard should display entry details', (WidgetTester tester) async {
    final entry = DiaryEntry(
      id: '1',
      date: DateTime(2023, 10, 24, 10, 30),
      title: 'Morning Walk',
      content: 'Beautiful morning at the park.',
      mood: '😊',
      location: 'Central Park',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EntryCard(entry: entry),
        ),
      ),
    );

    expect(find.text('Morning Walk'), findsOneWidget);
    expect(find.text('Beautiful morning at the park.'), findsOneWidget);
    expect(find.text('😊'), findsOneWidget);
    expect(find.text('Central Park'), findsOneWidget);
    expect(find.text('10:30 AM'), findsOneWidget);
  });
}
