import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/widgets/timeline_node.dart';

void main() {
  testWidgets('TimelineNode should render a circle and a line', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimelineNode(
            isFirst: true,
            isLast: false,
          ),
        ),
      ),
    );

    // Verify presence of the TimelineNode which contains the CustomPaint
    expect(find.byType(TimelineNode), findsOneWidget);
    expect(find.descendant(of: find.byType(TimelineNode), matching: find.byType(CustomPaint)), findsOneWidget);
  });
}
