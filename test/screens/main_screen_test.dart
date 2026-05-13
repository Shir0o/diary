import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/main.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
    ),
  ];

  Widget createApp() {
    return DiaryApp(entryStore: InMemoryDiaryEntryStore(testEntries));
  }

  testWidgets('menu button opens the main drawer', (tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('drawer destinations navigate to existing screens', (
    tester,
  ) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Total Entries'), findsOneWidget);
  });

  testWidgets('saving a new entry adds it to the timeline', (tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A saved diary entry');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('A saved diary entry'), findsWidgets);
  });

  testWidgets('editing an entry updates it in the timeline', (tester) async {
    await tester.pumpWidget(createApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Coffee Break'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Edited coffee entry');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edited coffee entry'), findsWidgets);
    expect(find.text('Coffee Break'), findsNothing);
  });
}
