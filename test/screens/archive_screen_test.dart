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

  testWidgets(
    'ArchiveScreen should display archived entries and allow unarchiving them',
    (WidgetTester tester) async {
      String? unarchivedId;

      await tester.pumpWidget(
        MaterialApp(
          home: ArchiveScreen(
            archivedEntries: [archivedEntry],
            onBackPressed: () {},
            onUnarchiveEntry: (id) => unarchivedId = id,
          ),
        ),
      );

      expect(find.text('Archived Entry'), findsOneWidget);
      expect(find.text('Unarchive'), findsOneWidget);

      await tester.tap(find.text('Unarchive'));
      await tester.pumpAndSettle();

      expect(unarchivedId, 'archived');
    },
  );
}
