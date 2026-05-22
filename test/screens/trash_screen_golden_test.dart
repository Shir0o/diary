@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/trash_screen.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/config/app_theme.dart';

void main() {
  group('TrashScreen Golden Tests', () {
    final mockEntries = [
      DiaryEntry(
        id: '1',
        date: DateTime(2026, 4, 24),
        title: 'Deleted Journal',
        content: 'This is a deleted entry.',
        mood: '🗑️',
        isDeleted: true,
      ),
    ];

    testGoldens('TrashScreen - appearance', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
        TrashScreen(
          deletedEntries: mockEntries,
          onBackPressed: () {},
          onRestoreEntry: (_) {},
          onPermanentlyDeleteEntry: (_) {},
          onEmptyTrash: () {},
          autoDeleteEnabled: true,
          retentionDays: 30,
        ),
        wrapper: (child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: child,
        ),
        surfaceSize: const Size(390, 844),
      );

      await screenMatchesGolden(tester, 'trash_screen_appearance');
    });
  });
}
