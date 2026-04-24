import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/widgets/side_drawer.dart';

void main() {
  Widget createWidgetUnderTest({required Function(int) onItemSelected, int selectedIndex = 0}) {
    return MaterialApp(
      home: Scaffold(
        drawer: SideDrawer(
          onItemSelected: onItemSelected,
          selectedIndex: selectedIndex,
        ),
        body: const Center(child: Text('Body')),
      ),
    );
  }

  testWidgets('SideDrawer renders header and navigation items', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(onItemSelected: (_) {}));

    // Open the drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    expect(find.text('Diary App'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Tapping an item calls onItemSelected', (WidgetTester tester) async {
    int? tappedIndex;
    await tester.pumpWidget(createWidgetUnderTest(
      onItemSelected: (index) => tappedIndex = index,
    ));

    // Open the drawer
    final ScaffoldState state = tester.firstState(find.byType(Scaffold));
    state.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(tappedIndex, equals(1));
  });
}
