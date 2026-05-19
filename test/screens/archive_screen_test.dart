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

  final deletedEntry = DiaryEntry(
    id: 'deleted',
    date: DateTime.now(),
    title: 'Deleted Entry',
    content: 'Content',
    mood: '🗑️',
    isDeleted: true,
    updatedAt: DateTime.now(),
  );

  testWidgets('ArchiveScreen displays entries, headers, and badges correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          deletedEntries: [deletedEntry],
          onMenuPressed: () {},
          onRestoreEntry: (_) {},
          onDeleteEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Archived Tab check
    expect(find.text('1 archived entries'), findsOneWidget);
    expect(find.text('Archived Entry'), findsOneWidget);

    // Switch to Trash tab
    await tester.tap(find.text('Trash'));
    await tester.pumpAndSettle();

    expect(find.text('1 items in trash'), findsOneWidget);
    expect(find.text('Deleted Entry'), findsOneWidget);
    // Auto-delete label
    expect(
      find.text('Items in Trash are permanently deleted after 30 days.'),
      findsOneWidget,
    );
    // Days remaining badge (could be 29 or 30 due to ms precision, but most likely 30)
    expect(find.textContaining('days left'), findsOneWidget);
    // Empty Trash button
    expect(find.widgetWithText(TextButton, 'Empty'), findsOneWidget);
  });

  testWidgets('ArchiveScreen swipe right to restore in Archived tab', (
    WidgetTester tester,
  ) async {
    String? restoredId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          deletedEntries: const [],
          onMenuPressed: () {},
          onRestoreEntry: (id) => restoredId = id,
          onDeleteEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Swipe right to restore (DismissDirection.startToEnd)
    await tester.drag(find.text('Archived Entry'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(restoredId, 'archived');
  });

  testWidgets('ArchiveScreen swipe left to trash in Archived tab', (
    WidgetTester tester,
  ) async {
    String? deletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          deletedEntries: const [],
          onMenuPressed: () {},
          onRestoreEntry: (_) {},
          onDeleteEntry: (id) => deletedId = id,
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Swipe left to trash (DismissDirection.endToStart)
    await tester.drag(find.text('Archived Entry'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(deletedId, 'archived');
  });

  testWidgets('ArchiveScreen empty trash confirmation works', (
    WidgetTester tester,
  ) async {
    bool emptyTrashCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: const [],
          deletedEntries: [deletedEntry],
          onMenuPressed: () {},
          onRestoreEntry: (_) {},
          onDeleteEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () => emptyTrashCalled = true,
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    await tester.tap(find.text('Trash'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Empty'));
    await tester.pumpAndSettle();

    expect(find.text('Empty Trash?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Empty Trash'));
    await tester.pumpAndSettle();

    expect(emptyTrashCalled, isTrue);
  });

  testWidgets('ArchiveScreen permanent delete confirmation works', (
    WidgetTester tester,
  ) async {
    String? permanentlyDeletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: const [],
          deletedEntries: [deletedEntry],
          onMenuPressed: () {},
          onRestoreEntry: (_) {},
          onDeleteEntry: (_) {},
          onPermanentlyDeleteEntry: (id) => permanentlyDeletedId = id,
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    await tester.tap(find.text('Trash'));
    await tester.pumpAndSettle();

    // Swipe left to delete forever
    await tester.drag(find.text('Deleted Entry'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Delete permanently?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete Forever'));
    await tester.pumpAndSettle();

    expect(permanentlyDeletedId, 'deleted');
  });
}
