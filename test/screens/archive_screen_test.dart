import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/archive_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final archivedEntry = DiaryEntry(
    id: 'archived',
    date: DateTime.now(),
    title: 'Archived Entry',
    content: 'Content',
    mood: '📦',
    isArchived: true,
    updatedAt: DateTime.now(),
  );

  testWidgets('ArchiveScreen displays entries and headers correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          onBackPressed: () {},
          onUnarchiveEntry: (_) {},
          onDeleteEntry: (_) {},
        ),
      ),
    );

    expect(find.text('1 archived entries'), findsOneWidget);
    expect(find.text('Archived Entry'), findsOneWidget);
    expect(
      find.text('Swipe right to restore, swipe left to trash.'),
      findsOneWidget,
    );
  });

  testWidgets('ArchiveScreen swipe right to restore', (
    WidgetTester tester,
  ) async {
    String? restoredId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          onBackPressed: () {},
          onUnarchiveEntry: (id) => restoredId = id,
          onDeleteEntry: (_) {},
        ),
      ),
    );

    // Swipe right to restore (DismissDirection.startToEnd)
    await tester.drag(find.text('Archived Entry'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(restoredId, 'archived');
  });

  testWidgets('ArchiveScreen swipe left to trash', (WidgetTester tester) async {
    String? deletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          onBackPressed: () {},
          onUnarchiveEntry: (_) {},
          onDeleteEntry: (id) => deletedId = id,
        ),
      ),
    );

    // Swipe left to trash (DismissDirection.endToStart)
    await tester.drag(find.text('Archived Entry'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deletedId, 'archived');
  });
}
