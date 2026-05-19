import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../helpers/analytics_helper.dart';
import '../helpers/font_helper.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<DiaryEntry> entries;
  final DateTime? referenceDate;
  final VoidCallback? onMenuPressed;

  const AnalyticsScreen({
    super.key,
    required this.entries,
    this.referenceDate,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalEntries = AnalyticsHelper.calculateTotalEntries(entries);
    final streak = AnalyticsHelper.calculateCurrentStreak(
      entries,
      relativeTo: referenceDate,
    );
    final moodDist = AnalyticsHelper.calculateMoodDistribution(entries);
    final tagDist = AnalyticsHelper.calculateTagDistribution(entries);
    final weeklyActivity = AnalyticsHelper.getWeeklyActivity(
      entries,
      relativeTo: referenceDate,
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Total Entries',
                  totalEntries.toString(),
                  Icons.book_outlined,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Current Streak',
                  '$streak days',
                  Icons.local_fire_department_outlined,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Mood Distribution', context),
          const SizedBox(height: 8),
          _buildMoodDistribution(moodDist, context),
          const SizedBox(height: 24),
          _buildSectionHeader('Tag Distribution', context),
          const SizedBox(height: 8),
          _buildTagDistribution(tagDist, context),
          const SizedBox(height: 24),
          _buildSectionHeader('Weekly Activity', context),
          const SizedBox(height: 8),
          _buildActivityChart(weeklyActivity, context),
          const SizedBox(height: 24),
          _buildInsightsCard(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: safeGoogleFont(
                'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: safeGoogleFont(
                'Inter',
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: safeGoogleFont(
        'Inter',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMoodDistribution(
    Map<String, int> distribution,
    BuildContext context,
  ) {
    if (distribution.isEmpty) {
      return _buildEmptyState(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final total = distribution.values.fold(0, (sum, val) => sum + val);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: distribution.entries.map((e) {
            final percentage = e.value / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: colorScheme.surfaceVariant,
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: safeGoogleFont(
                      'Inter',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTagDistribution(
    Map<String, int> distribution,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (distribution.isEmpty) {
      return Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'No tags used yet',
              style: safeGoogleFont(
                'Inter',
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final total = distribution.values.fold(0, (sum, val) => sum + val);

    final sortedEntries = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sortedEntries.map((e) {
            final percentage = e.value / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.label_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.key,
                      overflow: TextOverflow.ellipsis,
                      style: safeGoogleFont(
                        'Inter',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: colorScheme.surfaceVariant,
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${e.value} (${(percentage * 100).toStringAsFixed(0)}%)',
                    style: safeGoogleFont(
                      'Inter',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityChart(List<DayActivity> activity, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxCount = activity
        .map((e) => e.count)
        .fold(0, (max, e) => e > max ? e : max);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: activity.asMap().entries.map((entry) {
              final day = entry.value;
              final heightFactor = maxCount == 0
                  ? 0.05
                  : (day.count / maxCount).clamp(0.05, 1.0);

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 20,
                    height: 100 * heightFactor,
                    decoration: BoxDecoration(
                      color: day.count > 0
                          ? colorScheme.primary
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getWeekdayLabel(day.date),
                    style: safeGoogleFont(
                      'Inter',
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getWeekdayLabel(DateTime date) {
    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return weekdays[date.weekday - 1];
  }

  Widget _buildInsightsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.primary.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'ve been feeling 🚀 "Energetic" most of this week. Keep up the great work!',
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 14,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        'No data available',
        style: safeGoogleFont(
          'Inter',
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
