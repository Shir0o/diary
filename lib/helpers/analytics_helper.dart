import '../models/diary_entry.dart';

class DayActivity {
  final DateTime date;
  final int count;

  DayActivity(this.date, this.count);
}

class AnalyticsHelper {
  static int calculateTotalEntries(List<DiaryEntry> entries) {
    return entries.length;
  }

  static int calculateCurrentStreak(
    List<DiaryEntry> entries, {
    DateTime? relativeTo,
  }) {
    if (entries.isEmpty) return 0;

    final referenceDate = relativeTo ?? DateTime.now();
    final dates =
        entries
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime currentDay = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    // If no entry today, check if there was one yesterday to continue a streak
    if (!dates.contains(currentDay)) {
      currentDay = currentDay.subtract(const Duration(days: 1));
      if (!dates.contains(currentDay)) return 0;
    }

    while (dates.contains(currentDay)) {
      streak++;
      currentDay = currentDay.subtract(const Duration(days: 1));
    }

    return streak;
  }

  static Map<String, int> calculateMoodDistribution(List<DiaryEntry> entries) {
    final Map<String, int> distribution = {};
    for (var entry in entries) {
      distribution[entry.mood] = (distribution[entry.mood] ?? 0) + 1;
    }
    return distribution;
  }

  static List<DayActivity> getWeeklyActivity(
    List<DiaryEntry> entries, {
    DateTime? relativeTo,
  }) {
    final referenceDate = relativeTo ?? DateTime.now();
    final List<DayActivity> activity = [];

    for (int i = 6; i >= 0; i--) {
      final date = referenceDate.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);

      final count = entries.where((e) {
        final eDate = DateTime(e.date.year, e.date.month, e.date.day);
        return eDate.isAtSameMomentAs(dayStart);
      }).length;

      activity.add(DayActivity(dayStart, count));
    }

    return activity;
  }

  static Map<String, int> calculateTagDistribution(List<DiaryEntry> entries) {
    final Map<String, int> distribution = {};
    for (final entry in entries) {
      for (final tag in entry.tags) {
        distribution[tag] = (distribution[tag] ?? 0) + 1;
      }
    }
    return distribution;
  }
}
