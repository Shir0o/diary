import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';
import '../helpers/analytics_helper.dart';
import '../widgets/skeleton_loader.dart';

class AnalyticsScreen extends StatefulWidget {
  final ThemeService? themeService;
  final List<DiaryEntry> entries;
  final DateTime? referenceDate;
  final VoidCallback onBackPressed;
  final bool isLoading;

  const AnalyticsScreen({
    super.key,
    this.themeService,
    required this.entries,
    this.referenceDate,
    required this.onBackPressed,
    this.isLoading = false,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = 'All Time';

  List<DiaryEntry> get _filteredEntries {
    if (_selectedRange == 'All Time') return widget.entries;

    final now = widget.referenceDate ?? DateTime.now();
    final cutoff = switch (_selectedRange) {
      '7 Days' => now.subtract(const Duration(days: 7)),
      '30 Days' => now.subtract(const Duration(days: 30)),
      '90 Days' => now.subtract(const Duration(days: 90)),
      _ => now,
    };

    return widget.entries.where((e) => e.date.isAfter(cutoff)).toList();
  }

  int _calculateTotalWords(List<DiaryEntry> entries) {
    return entries.fold<int>(0, (sum, entry) {
      final words = entry.content
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty);
      return sum + words.length;
    });
  }

  String _calculateAverageMood(List<DiaryEntry> entries) {
    if (entries.isEmpty) return '📝';
    final Map<String, int> counts = {};
    for (var entry in entries) {
      counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
    }
    String bestMood = '📝';
    int maxCount = 0;
    counts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        bestMood = mood;
      }
    });
    return bestMood;
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case '😊':
        return 'Happy';
      case '😌':
        return 'Calm';
      case '😍':
        return 'Love';
      case '😔':
        return 'Down';
      case '😴':
        return 'Tired';
      case '🥳':
        return 'Proud';
      default:
        return 'Good';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    String palette = 'lilac';
    try {
      palette = widget.themeService?.themePalette ?? 'lilac';
    } catch (_) {}

    final bgGradient = AppTheme.getScreenBackground(brightness, palette);
    final headingColor = AppTheme.getHeadingColor(brightness);

    final filtered = _filteredEntries;
    final totalEntries = AnalyticsHelper.calculateTotalEntries(filtered);
    final streak = AnalyticsHelper.calculateCurrentStreak(
      filtered,
      relativeTo: widget.referenceDate,
    );
    final totalWords = _calculateTotalWords(filtered);
    final avgMood = _calculateAverageMood(filtered);

    final moodDist = AnalyticsHelper.calculateMoodDistribution(filtered);
    final tagDist = AnalyticsHelper.calculateTagDistribution(filtered);

    return Scaffold(
      backgroundColor: bgGradient.colors.first,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBackPressed,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.getCardBackground(
                            brightness,
                            palette,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.arrow_back, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Analytics',
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Body
              Expanded(
                child: widget.isLoading
                    ? const AnalyticsScreenSkeleton()
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        children: [
                          _buildRangeSelector(brightness, palette),
                          const SizedBox(height: 8),

                          // Highlights section
                          Text(
                            "HIGHLIGHTS",
                            style: safeGoogleFont(
                              'Space Mono',
                              color: AppTheme.getFaintColor(brightness),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildHighlightsCard(
                            brightness,
                            palette,
                            totalEntries,
                            totalWords,
                            streak,
                            avgMood,
                          ),
                          const SizedBox(height: 12),

                          // Mood Distribution Section
                          Text(
                            "Mood Distribution",
                            style: safeGoogleFont(
                              'Space Mono',
                              color: AppTheme.getFaintColor(brightness),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildMoodDistributionCard(
                            brightness,
                            palette,
                            moodDist,
                            totalEntries,
                          ),
                          const SizedBox(height: 12),

                          // Popular Tags Section
                          Text(
                            "POPULAR TAGS",
                            style: safeGoogleFont(
                              'Space Mono',
                              color: AppTheme.getFaintColor(brightness),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildPopularTagsCard(
                            brightness,
                            palette,
                            tagDist,
                            totalEntries,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSelector(Brightness brightness, String palette) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['7 Days', '30 Days', '90 Days', 'All Time'].map((range) {
          final isSelected = _selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRange = range;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppTheme.getAccentGradient(palette)
                      : null,
                  color: isSelected
                      ? null
                      : AppTheme.getCardBackground(brightness, palette),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.getPrimaryColor(
                              palette,
                            ).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppTheme.getHairlineColor(brightness),
                        ),
                ),
                child: Text(
                  range,
                  style: safeGoogleFont(
                    'Quicksand',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getMutedColor(brightness),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHighlightsCard(
    Brightness brightness,
    String palette,
    int totalEntries,
    int totalWords,
    int streak,
    String avgMood,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(brightness, palette),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: [
          _buildStatItem(brightness, 'Total Entries', '$totalEntries', '📝'),
          _buildStatItem(brightness, 'Total words', '$totalWords words', '✍️'),
          _buildStatItem(brightness, 'Current Streak', '$streak days', '🔥'),
          _buildStatItem(
            brightness,
            'Average mood',
            '${_getMoodLabel(avgMood)} $avgMood',
            '🎭',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    Brightness brightness,
    String label,
    String value,
    String emoji,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: safeGoogleFont(
                  'Quicksand',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getFaintColor(brightness),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: safeGoogleFont(
            'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.getHeadingColor(brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodDistributionCard(
    Brightness brightness,
    String palette,
    Map<String, int> moodDist,
    int total,
  ) {
    final themePrimary = AppTheme.getPrimaryColor(palette);
    final activeMoods = moodDist.keys
        .where((k) => (moodDist[k] ?? 0) > 0)
        .toList();
    final moods = activeMoods.isNotEmpty
        ? activeMoods
        : ['😊', '😌', '😍', '😔', '😴', '🥳'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(brightness, palette),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
      ),
      child: total == 0
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No data available',
                  style: safeGoogleFont(
                    'Quicksand',
                    fontSize: 13,
                    color: AppTheme.getFaintColor(brightness),
                  ),
                ),
              ),
            )
          : Column(
              children: moods.map((mood) {
                final count = moodDist[mood] ?? 0;
                final double pct = total == 0 ? 0.0 : count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(mood, style: const TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: AppTheme.getChipColor(brightness),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              themePrimary,
                            ),
                            minHeight: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${(pct * 100).toInt()}%',
                          style: safeGoogleFont(
                            'Space Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getMutedColor(brightness),
                          ),
                          textAlign: Alignment.centerRight.x == 1.0
                              ? TextAlign.right
                              : TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildPopularTagsCard(
    Brightness brightness,
    String palette,
    Map<String, int> tagDist,
    int total,
  ) {
    final sortedTags = tagDist.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTags.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackground(brightness, palette),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.getHairlineColor(brightness)),
        ),
        child: Center(
          child: Text(
            'No tags found yet.',
            style: safeGoogleFont(
              'Quicksand',
              color: AppTheme.getFaintColor(brightness),
            ),
          ),
        ),
      );
    }

    final maxCount = sortedTags.first.value;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(brightness, palette),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
      ),
      child: Column(
        children: sortedTags.take(5).map((entry) {
          final tag = entry.key;
          final count = entry.value;
          final double pct = maxCount == 0 ? 0.0 : count / maxCount;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '#$tag',
                    style: safeGoogleFont(
                      'Quicksand',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getMutedColor(brightness),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppTheme.getChipColor(brightness),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF7A63C9),
                      ),
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 24,
                  child: Text(
                    '$count',
                    style: safeGoogleFont(
                      'Space Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getFaintColor(brightness),
                    ),
                    textAlign: Alignment.centerRight.x == 1.0
                        ? TextAlign.right
                        : TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
