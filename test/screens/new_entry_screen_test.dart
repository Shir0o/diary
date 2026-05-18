import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/screens/new_entry_screen.dart';

void main() {
  testWidgets('NewEntryScreen should display all required UI elements', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));

    // Top App Bar elements
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('New Entry'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Date & Time header (partial match as it might contain current date)
    expect(find.byType(Text), findsAtLeastNWidgets(2)); // Date and time

    // Main Text Input
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Write your heart out...'), findsOneWidget);

    // Bottom Toolbar icons
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.label_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mood_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);

    // Status indicator
    expect(find.text('Saved locally'), findsOneWidget);
  });

  testWidgets('Entering text should update the TextField', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));

    const testText = 'My secret diary entry';
    await tester.enterText(find.byType(TextField), testText);
    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('Save returns a diary entry with entered content', (
    WidgetTester tester,
  ) async {
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(context).push<DiaryEntry>(
                  MaterialPageRoute(builder: (_) => const NewEntryScreen()),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Saved entry body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.title, 'Saved entry body');
    expect(savedEntry!.content, 'Saved entry body');
  });

  testWidgets('Editing pre-fills content and returns the same entry id', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(context).push<DiaryEntry>(
                  MaterialPageRoute(
                    builder: (_) => NewEntryScreen(entry: existingEntry),
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Original body'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Updated body');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.id, 'entry-1');
    expect(savedEntry!.content, 'Updated body');
  });

  testWidgets('Delete icon is hidden when creating a new entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NewEntryScreen()));
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('Delete icon is hidden when editing without onDelete', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    await tester.pumpWidget(
      MaterialApp(home: NewEntryScreen(entry: existingEntry)),
    );
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('Confirming delete invokes onDelete and pops the screen', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    var deleteCalls = 0;
    var routePopped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                await Navigator.of(context).push<DiaryEntry>(
                  MaterialPageRoute(
                    builder: (_) => NewEntryScreen(
                      entry: existingEntry,
                      onDelete: () async {
                        deleteCalls++;
                      },
                    ),
                  ),
                );
                routePopped = true;
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete entry?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 1);
    expect(routePopped, isTrue);
  });

  testWidgets('Cancelling delete does not invoke onDelete or pop', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    var deleteCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: NewEntryScreen(
          entry: existingEntry,
          onDelete: () async {
            deleteCalls++;
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalls, 0);
    expect(find.text('Edit Entry'), findsOneWidget);
  });

  testWidgets('Clearing content while editing returns untitled entry', (
    WidgetTester tester,
  ) async {
    final existingEntry = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 10),
      title: 'Original title',
      content: 'Original body',
      mood: '🚀',
    );
    DiaryEntry? savedEntry;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                savedEntry = await Navigator.of(context).push<DiaryEntry>(
                  MaterialPageRoute(
                    builder: (_) => NewEntryScreen(entry: existingEntry),
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(savedEntry, isNotNull);
    expect(savedEntry!.title, 'Untitled Entry');
    expect(savedEntry!.content, isEmpty);
  });
}
