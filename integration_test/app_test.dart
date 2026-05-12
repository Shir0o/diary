import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:diary/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('navigate to New Entry and back', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the Timeline screen
      expect(find.text('Diary'), findsOneWidget);

      // Find and tap the FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify we are on the New Entry screen
      expect(find.text('New Entry'), findsOneWidget);
      expect(find.text('Write your heart out...'), findsOneWidget);

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Integration test entry');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify we are back on the Timeline screen
      expect(find.text('Diary'), findsOneWidget);
    });

    testWidgets('navigate to New Entry and use back button', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify we are on the New Entry screen
      expect(find.text('New Entry'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we are back on the Timeline screen
      expect(find.text('Diary'), findsOneWidget);
    });

    testWidgets('navigate between Timeline and Settings from drawer', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we start on Timeline
      expect(find.text('Diary'), findsOneWidget);

      // Open the drawer and tap Settings.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();

      // Verify we are on the Settings screen
      expect(find.text('Settings').first, findsOneWidget);
      expect(find.text('SECURITY & APPEARANCE'), findsOneWidget);

      // Open the drawer and tap Timeline to go back.
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Timeline').last);
      await tester.pumpAndSettle();

      // Verify we are back on Timeline
      expect(find.text('Diary'), findsOneWidget);
    });
  });
}
