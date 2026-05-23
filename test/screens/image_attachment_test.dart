import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/new_entry_screen.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('NewEntryScreen can render attached images', (tester) async {
    final entry = DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Title',
      content: 'Content',
      mood: '🚀',
      imageUrls: const ['path/to/local/image.png'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NewEntryScreen(entry: entry)),
      ),
    );

    // Verify it builds, text field and images layout render
    expect(find.text('Content'), findsOneWidget);
    expect(find.byType(Image), findsWidgets);
  });
}
