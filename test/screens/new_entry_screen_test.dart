import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/new_entry_screen.dart';

void main() {
  testWidgets('NewEntryScreen should display all required UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NewEntryScreen(),
    ));

    // Top App Bar elements
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.text('New Entry'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Date & Time header (partial match as it might contain current date)
    expect(find.byType(Text), findsAtLeastNWidgets(2)); // Date and time

    // Main Text Input
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Write your heart out...'), findsOneWidget);

    // Bottom Toolbar icons
    expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    expect(find.byIcon(Icons.label_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mood_outlined), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    
    // Status indicator
    expect(find.text('Saving...'), findsOneWidget);
  });

  testWidgets('Entering text should update the TextField', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: NewEntryScreen(),
    ));

    const testText = 'My secret diary entry';
    await tester.enterText(find.byType(TextField), testText);
    expect(find.text(testText), findsOneWidget);
  });
}
