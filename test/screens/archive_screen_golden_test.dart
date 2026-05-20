@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/screens/archive_screen.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/config/app_theme.dart';

void main() {
  group('ArchiveScreen Golden Tests', () {
    final mockEntries = [
      DiaryEntry(
        id: '1',
        date: DateTime(2026, 4, 24),
        title: 'Archived Journal',
        content: 'This is an archived entry.',
        mood: '📦',
        isArchived: true,
      ),
    ];

    testGoldens('ArchiveScreen - appearance', (WidgetTester tester) async {
      await tester.pumpWidgetBuilder(
        ArchiveScreen(
          archivedEntries: mockEntries,
          onBackPressed: () {},
          onUnarchiveEntry: (_) {},
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

      await screenMatchesGolden(tester, 'archive_screen_appearance');
    });
  });
}
