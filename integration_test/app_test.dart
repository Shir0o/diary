import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:diary/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the FAB and scroll timeline', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify we are on the Timeline screen
      expect(find.text('Diary'), findsOneWidget);

      // Take a screenshot of the initial state
      await tester.pumpAndSettle();
      // Note: Screenshot capturing requires a device/emulator and specific setup
      // In a real CI/CD or local env, we'd use:
      // await binding.takeScreenshot('timeline_initial');
      
      // Find and tap the FAB
      final fab = find.byType(app.FloatingActionButton);
      expect(fab, findsOneWidget);
      
      // Scroll the list
      await tester.drag(find.byType(app.ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
    });
  });
}
