import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diary/screens/settings_screen.dart';
import 'package:diary/providers/diary_provider.dart';
import 'package:diary/providers/theme_provider.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  Widget createSettingsScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  testWidgets('SettingsScreen should display all required sections and items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle(); // Allow providers to initialize

    // Top App Bar
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Section Headers
    expect(find.text('DATA & PRIVACY'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);

    // Data & Appearance Items
    expect(find.text('Local storage'), findsOneWidget);
    expect(find.text('Entries are saved on this device.'), findsOneWidget);
    expect(find.text('Device privacy'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);

    // Footer
    expect(find.text('Version 0.1.0'), findsOneWidget);
  });

  testWidgets('SettingsScreen should not expose placeholder switches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    expect(find.byType(Switch), findsNothing);
    expect(find.textContaining('Google Drive'), findsNothing);
  });

  testWidgets('Theme setting opens theme selector', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createSettingsScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();

    expect(find.text('Select theme'), findsOneWidget);
    expect(find.text('System default'), findsWidgets);
    expect(find.text('Light mode'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });
}
