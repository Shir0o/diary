import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/info_screen.dart';

void main() {
  group('InfoScreen Widget Tests', () {
    testWidgets('Help screen renders all expected sections', (
      WidgetTester tester,
    ) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InfoScreen.help(onBackPressed: () => backPressed = true),
        ),
      );

      // Verify basic app bar and title
      expect(find.text('Help'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Verify specific section titles and contents
      expect(find.text('Writing entries'), findsOneWidget);
      expect(find.text('Reviewing your diary'), findsOneWidget);
      expect(find.text('Backup and privacy'), findsOneWidget);
      expect(find.text('Security and biometrics'), findsOneWidget);

      expect(find.textContaining('SQLite database'), findsOneWidget);
      expect(find.textContaining('secure biometric API'), findsOneWidget);

      // Test back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(backPressed, isTrue);
    });

    testWidgets('About screen renders all expected sections', (
      WidgetTester tester,
    ) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InfoScreen.about(onBackPressed: () => backPressed = true),
        ),
      );

      // Verify basic app bar and title
      expect(find.text('About'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      // Verify specific section titles
      expect(find.text('Diary'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('Privacy Declaration'), findsOneWidget);

      expect(find.text('0.1.0'), findsOneWidget);
      expect(find.textContaining('privacy-first principles'), findsOneWidget);
      expect(
        find.textContaining('Google Drive synchronization'),
        findsOneWidget,
      );

      // Test back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(backPressed, isTrue);
    });
  });
}
