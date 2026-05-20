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
  );

  testWidgets(
    'TrashScreen should display deleted entries and allow restoring or permanently deleting them',
    (WidgetTester tester) async {
      String? restoredId;
      String? permanentlyDeletedId;

      await tester.pumpWidget(
        MaterialApp(
          home: TrashScreen(
            deletedEntries: [deletedEntry],
            onBackPressed: () {},
            onRestoreEntry: (id) => restoredId = id,
            onPermanentlyDeleteEntry: (id) => permanentlyDeletedId = id,
          ),
        ),
      );

      expect(find.text('Deleted Entry'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Delete Forever'), findsOneWidget);

      // Test restore
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      expect(restoredId, 'deleted');

      // Test delete forever cancellation
      await tester.tap(find.widgetWithText(TextButton, 'Delete Forever').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete permanently?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(permanentlyDeletedId, null);

      // Test delete forever confirmation
      await tester.tap(find.widgetWithText(TextButton, 'Delete Forever').first);
      await tester.pumpAndSettle();
      expect(find.text('Delete permanently?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete Forever').last);
      await tester.pumpAndSettle();
      expect(permanentlyDeletedId, 'deleted');
    },
  );
}
