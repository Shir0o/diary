import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/timeline_screen.dart';

void main() {
  testWidgets('TimelineScreen should render entries and FAB', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TimelineScreen()));

    expect(find.text('Diary'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Initially should show our mock entries
    expect(find.text('Today'), findsOneWidget);
  });
}
