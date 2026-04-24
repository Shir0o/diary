import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diary/screens/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen should display all required sections and items', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SettingsScreen(),
    ));

    // Top App Bar
    expect(find.text('Settings'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // Section Headers
    expect(find.text('SECURITY & APPEARANCE'), findsOneWidget);
    expect(find.text('CLOUD BACKUP'), findsOneWidget);

    // Security & Appearance Items
    expect(find.text('Biometric Lock'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System Default'), findsOneWidget);
    expect(find.byType(Switch), findsAtLeastNWidgets(1));

    // Cloud Backup Items
    expect(find.text('Auto-backup'), findsOneWidget);
    expect(find.text('Back up your diary entries to Google Drive automatically.'), findsOneWidget);
    expect(find.text('Backup to Google Drive'), findsOneWidget);
    expect(find.textContaining('Last backup:'), findsOneWidget);

    // Footer
    expect(find.text('Your data is encrypted locally.'), findsOneWidget);
    expect(find.text('Version 2.4.0'), findsOneWidget);
  });

  testWidgets('Toggling switches should update state (UI check)', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: SettingsScreen(),
    ));

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));

    // Toggle biometric lock
    await tester.tap(switches.first);
    await tester.pump();
    
    // Toggle auto-backup
    await tester.tap(switches.last);
    await tester.pump();
  });
}
