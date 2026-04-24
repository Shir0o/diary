import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:diary/widgets/entry_card.dart';
import 'package:diary/models/diary_entry.dart';

void main() {
  testGoldens('EntryCard - appearance', (tester) async {
    final entry = DiaryEntry(
      id: '1',
      date: DateTime(2023, 10, 24, 10, 30),
      title: 'Golden Test Entry',
      content: 'Testing the visual appearance of our entry card.',
      mood: '✨',
      location: 'Testing Lab',
    );

    final builder = GoldenBuilder.column()
      ..addScenario('Default Entry Card', EntryCard(entry: entry));

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'entry_card_appearance');
  });
}
