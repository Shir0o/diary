import 'package:flutter_test/flutter_test.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/helpers/analytics_helper.dart';

void main() {
  final entries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24),
      title: 'T1',
      content: 'C1',
      mood: '🚀',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 23),
      title: 'T2',
      content: 'C2',
      mood: '🚀',
    ),
    DiaryEntry(
      id: '3',
      date: DateTime(2026, 4, 22),
      title: 'T3',
      content: 'C3',
      mood: '☕',
    ),
    DiaryEntry(
      id: '4',
      date: DateTime(2026, 4, 20),
      title: 'T4',
      content: 'C4',
      mood: '📝',
    ),
  ];

  test('calculateTotalEntries returns correct count', () {
    expect(AnalyticsHelper.calculateTotalEntries(entries), equals(4));
  });

  test('calculateCurrentStreak returns correct streak', () {
    // 24, 23, 22 is a 3-day streak. 21 is missing.
    // Assuming "today" is 2026-04-24
    final today = DateTime(2026, 4, 24);
    expect(
      AnalyticsHelper.calculateCurrentStreak(entries, relativeTo: today),
      equals(3),
    );
  });

  test('calculateMoodDistribution returns correct frequencies', () {
    final dist = AnalyticsHelper.calculateMoodDistribution(entries);
    expect(dist['🚀'], equals(2));
    expect(dist['☕'], equals(1));
    expect(dist['📝'], equals(1));
  });

  test('getWeeklyActivity returns entry counts for last 7 days', () {
    final today = DateTime(2026, 4, 24);
    final activity = AnalyticsHelper.getWeeklyActivity(
      entries,
      relativeTo: today,
    );

    expect(activity.length, equals(7));
    expect(activity[6].count, equals(1)); // Today (24)
    expect(activity[5].count, equals(1)); // Yesterday (23)
    expect(activity[4].count, equals(1)); // 22
    expect(activity[3].count, equals(0)); // 21
    expect(activity[2].count, equals(1)); // 20
  });
}
