import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/timeline_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  testWidgets('TimelineScreen should render entries and FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TimelineScreen()));

    expect(find.text('Diary'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Initially should show our mock entries
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('TimelineScreen should support swipe-to-delete', (
    WidgetTester tester,
  ) async {
    final entry = DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Title',
      content: 'Content',
      mood: '🚀',
    );
    String? deletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          entries: [entry],
          onDeleteEntry: (id) => deletedId = id,
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);

    // Swipe left (end to start) to delete
    await tester.drag(find.text('Title'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(deletedId, '1');
  });

  testWidgets('TimelineScreen should support swipe-to-archive', (
    WidgetTester tester,
  ) async {
    final entry = DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Title',
      content: 'Content',
      mood: '🚀',
    );
    String? archivedId;

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineScreen(
          entries: [entry],
          onArchiveEntry: (id) => archivedId = id,
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);

    // Swipe right (start to end) to archive
    await tester.drag(find.text('Title'), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(archivedId, '1');
  });
}
