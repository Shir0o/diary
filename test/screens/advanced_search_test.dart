import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/entry_search_delegate.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final entries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24),
      title: 'Project Launch',
      content: 'Launching our brand new flutter diary application.',
      mood: '🚀',
      tags: const ['work', 'flutter'],
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 23),
      title: 'Relaxing coffee',
      content: 'Enjoying some hot brew at a nice cafe.',
      mood: '☕',
      tags: const ['personal', 'coffee'],
      imageUrls: const ['path/to/image.png'],
    ),
  ];

  testWidgets('EntrySearchDelegate filters by text search', (tester) async {
    final delegate = EntrySearchDelegate(entries);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showSearch(context: context, delegate: delegate),
              child: const Text('Search'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    // Type query
    delegate.query = 'coffee';
    await tester.pump();

    // Should find the coffee entry
    expect(find.text('Relaxing coffee'), findsOneWidget);
    expect(find.text('Project Launch'), findsNothing);
  });

  testWidgets('EntrySearchDelegate renders advanced filter chips', (
    tester,
  ) async {
    final delegate = EntrySearchDelegate(entries);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showSearch(context: context, delegate: delegate),
              child: const Text('Search'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    // Verify filter chips render in filter bar
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('Tag'), findsOneWidget);
    expect(find.text('Date Range'), findsOneWidget);
    expect(find.text('Has Images'), findsOneWidget);
  });
}
