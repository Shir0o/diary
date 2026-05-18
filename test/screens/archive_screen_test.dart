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
  );

  final deletedEntry = DiaryEntry(
    id: 'deleted',
    date: DateTime.now(),
    title: 'Deleted Entry',
    content: 'Content',
    mood: '🗑️',
    isDeleted: true,
  );

  testWidgets('ArchiveScreen should display archived and deleted entries in tabs', (
    WidgetTester tester,
  ) async {
    String? restoredId;
    String? deletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: ArchiveScreen(
          archivedEntries: [archivedEntry],
          deletedEntries: [deletedEntry],
          onMenuPressed: () {},
          onRestoreEntry: (id) => restoredId = id,
          onPermanentlyDeleteEntry: (id) => deletedId = id,
        ),
      ),
    );

    expect(find.text('Archived Entry'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);

    // Switch to Trash tab
    await tester.tap(find.text('Trash'));
    await tester.pumpAndSettle();

    expect(find.text('Deleted Entry'), findsOneWidget);
    expect(find.text('Restore'), findsOneWidget);
    expect(find.text('Delete Forever'), findsOneWidget);

    // Test restore from Trash
    await tester.tap(find.text('Restore'));
    expect(restoredId, 'deleted');

    // Test delete forever
    await tester.tap(find.widgetWithText(TextButton, 'Delete Forever').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete permanently?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete Forever').last);
    expect(deletedId, 'deleted');
  });
}
