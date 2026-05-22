import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/trash_screen.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  final deletedEntry = DiaryEntry(
    id: 'deleted',
    date: DateTime.now(),
    title: 'Deleted Entry',
    content: 'Content',
    mood: '🗑️',
    isDeleted: true,
    updatedAt: DateTime.now(),
  );

  testWidgets('TrashScreen displays entries, headers, and badges correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TrashScreen(
          deletedEntries: [deletedEntry],
          onBackPressed: () {},
          onRestoreEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    expect(find.text('1 items in trash'), findsOneWidget);
    expect(find.text('Deleted Entry'), findsOneWidget);
    expect(
      find.text('Items in Trash are permanently deleted after 30 days.'),
      findsOneWidget,
    );
    expect(find.textContaining('days left'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Empty'), findsOneWidget);
  });

  testWidgets('TrashScreen swipe right to restore', (
    WidgetTester tester,
  ) async {
    String? restoredId;

    await tester.pumpWidget(
      MaterialApp(
        home: TrashScreen(
          deletedEntries: [deletedEntry],
          onBackPressed: () {},
          onRestoreEntry: (id) => restoredId = id,
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Swipe right to restore (DismissDirection.startToEnd)
    await tester.drag(find.text('Deleted Entry'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(restoredId, 'deleted');
  });

  testWidgets('TrashScreen swipe left to delete forever - confirm and cancel', (
    WidgetTester tester,
  ) async {
    String? permanentlyDeletedId;

    await tester.pumpWidget(
      MaterialApp(
        home: TrashScreen(
          deletedEntries: [deletedEntry],
          onBackPressed: () {},
          onRestoreEntry: (_) {},
          onPermanentlyDeleteEntry: (id) => permanentlyDeletedId = id,
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Swipe left to delete forever (DismissDirection.endToStart)
    await tester.drag(find.text('Deleted Entry'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Delete permanently?'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(permanentlyDeletedId, isNull);

    // Swipe left again
    await tester.drag(find.text('Deleted Entry'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Tap Delete Forever
    await tester.tap(find.widgetWithText(TextButton, 'Delete Forever'));
    await tester.pumpAndSettle();
    expect(permanentlyDeletedId, 'deleted');
  });

  testWidgets('TrashScreen empty trash button works', (
    WidgetTester tester,
  ) async {
    bool emptyTrashCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TrashScreen(
          deletedEntries: [deletedEntry],
          onBackPressed: () {},
          onRestoreEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () => emptyTrashCalled = true,
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
      ),
    );

    // Tap Empty button
    await tester.tap(find.widgetWithText(TextButton, 'Empty'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Empty Trash?'), findsOneWidget);

    // Tap Empty Trash
    await tester.tap(find.widgetWithText(TextButton, 'Empty Trash'));
    await tester.pumpAndSettle();

    expect(emptyTrashCalled, isTrue);
  });
}
