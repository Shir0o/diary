import 'package:diary/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menu button opens the main drawer', (tester) async {
    await tester.pumpWidget(const DiaryApp());

    expect(find.byType(BottomNavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsWidgets);
    expect(find.text('Calendar'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('drawer destinations navigate to existing screens', (
    tester,
  ) async {
    await tester.pumpWidget(const DiaryApp());

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar').last);
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analytics').last);
    await tester.pumpAndSettle();

    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Total Entries'), findsOneWidget);
  });

  testWidgets('saving a new entry adds it to the timeline', (tester) async {
    await tester.pumpWidget(const DiaryApp());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A saved diary entry');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('A saved diary entry'), findsWidgets);
  });

  testWidgets('editing an entry updates it in the timeline', (tester) async {
    await tester.pumpWidget(const DiaryApp());

    await tester.tap(find.text('Coffee Break'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Edited coffee entry');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Edited coffee entry'), findsWidgets);
    expect(find.text('Coffee Break'), findsNothing);
  });
}
