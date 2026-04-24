import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../helpers/analytics_helper.dart';
import '../helpers/font_helper.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<DiaryEntry> entries;
  final DateTime? referenceDate;

  const AnalyticsScreen({
    super.key,
    required this.entries,
    this.referenceDate,
  });

  @override
  Widget build(BuildContext context) {
    final totalEntries = AnalyticsHelper.calculateTotalEntries(entries);
    final streak = AnalyticsHelper.calculateCurrentStreak(entries, relativeTo: referenceDate);
    final moodDist = AnalyticsHelper.calculateMoodDistribution(entries);
    final weeklyActivity = AnalyticsHelper.getWeeklyActivity(entries, relativeTo: referenceDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
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
                  const Color(0xFF6751a4),
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
          _buildSectionHeader('Mood Distribution'),
          const SizedBox(height: 8),
          _buildMoodDistribution(moodDist),
          const SizedBox(height: 24),
          _buildSectionHeader('Weekly Activity'),
          const SizedBox(height: 8),
          _buildActivityChart(weeklyActivity),
          const SizedBox(height: 24),
          _buildInsightsCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
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
                color: const Color(0xFF1D1B20),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: safeGoogleFont(
                'Inter',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: safeGoogleFont(
        'Inter',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1D1B20),
      ),
    );
  }

  Widget _buildMoodDistribution(Map<String, int> distribution) {
    if (distribution.isEmpty) {
      return _buildEmptyState();
    }

    final total = distribution.values.fold(0, (sum, val) => sum + val);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
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
                          backgroundColor: const Color(0xFFF3EDF7),
                          color: const Color(0xFF6751a4),
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: safeGoogleFont('Inter', fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActivityChart(List<DayActivity> activity) {
    final maxCount = activity.map((e) => e.count).fold(0, (max, e) => e > max ? e : max);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S']; // Simplified labels

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: activity.asMap().entries.map((entry) {
              final idx = entry.key;
              final day = entry.value;
              final heightFactor = maxCount == 0 ? 0.05 : (day.count / maxCount).clamp(0.05, 1.0);
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 20,
                    height: 100 * heightFactor,
                    decoration: BoxDecoration(
                      color: day.count > 0 ? const Color(0xFF6751a4) : const Color(0xFFF3EDF7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getWeekdayLabel(day.date),
                    style: safeGoogleFont('Inter', fontSize: 10, color: Colors.grey),
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

  Widget _buildInsightsCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFF6751a4).withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF6751a4), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF6751a4), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You\'ve been feeling 🚀 "Energetic" most of this week. Keep up the great work!',
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 14,
                  color: const Color(0xFF6751a4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        'No data available',
        style: safeGoogleFont('Inter', color: Colors.grey),
      ),
    );
  }
}
