import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/entry_card.dart';

class CalendarScreen extends StatefulWidget {
  final ThemeService? themeService;
  final DateTime? initialDate;
  final VoidCallback onBackPressed;
  final VoidCallback? onSearchEntries;
  final ValueChanged<DiaryEntry>? onEditEntry;
  final List<DiaryEntry>? entries;
  final bool isLoading;

  const CalendarScreen({
    super.key,
    this.themeService,
    this.initialDate,
    required this.onBackPressed,
    this.onSearchEntries,
    this.onEditEntry,
    this.entries,
    this.isLoading = false,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  static final List<DiaryEntry> _defaultEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content:
          'Today I started the Diary app project. It\'s going to be a great journey of building something meaningful.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content:
          'Had a wonderful cup of coffee while thinking about the UI design.',
      mood: '☕',
      location: 'Local Cafe',
    ),
    DiaryEntry(
      id: '3',
      date: DateTime(2026, 4, 23, 11, 0),
      title: 'Planning phase',
      content: 'Spent the day planning the features and architecture.',
      mood: '📝',
    ),
  ];

  List<DiaryEntry> get _entries => widget.entries ?? _defaultEntries;

  List<DiaryEntry> get _filteredEntries {
    return _entries.where((entry) {
      return !entry.isArchived &&
          entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
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
    final bodyColor = AppTheme.getBodyColor(brightness);

    return Scaffold(
      backgroundColor: bgGradient.colors.first,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Redesigned Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: widget.onBackPressed,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Calendar',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: widget.onSearchEntries,
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
                          child: Text('🔍', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Body
              Expanded(
                child: widget.isLoading
                    ? const CalendarScreenSkeleton()
                    : Column(
                        children: [
                          Offstage(
                            child: CalendarDatePicker(
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              onDateChanged: (date) {
                                setState(() {
                                  _selectedDate = date;
                                  _currentMonth = DateTime(
                                    date.year,
                                    date.month,
                                  );
                                });
                              },
                            ),
                          ),
                          Flexible(
                            child: _buildCustomCalendar(brightness, palette),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                DateFormat(
                                  'EEEE, MMM d, yyyy',
                                ).format(_selectedDate).toUpperCase(),
                                style: safeGoogleFont(
                                  'Space Mono',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getFaintColor(brightness),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: _filteredEntries.isEmpty
                                ? _buildEmptyDayState(headingColor, bodyColor)
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 4,
                                    ),
                                    itemCount: _filteredEntries.length,
                                    itemBuilder: (context, index) {
                                      final entry = _filteredEntries[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: EntryCard(
                                          entry: entry,
                                          onTap: () {
                                            if (widget.onEditEntry != null) {
                                              widget.onEditEntry!(entry);
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstWeekdayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  Widget _buildCustomCalendar(Brightness brightness, String palette) {
    final days = _daysInMonth(_currentMonth);
    final firstWeekday = _firstWeekdayOfMonth(_currentMonth);

    final List<DateTime?> cells = [];
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(null);
    }
    for (int i = 1; i <= days; i++) {
      cells.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    final today = DateTime.now();

    // Map entries to string keys for fast lookup
    final Map<String, List<DiaryEntry>> entryMap = {};
    for (var entry in _entries) {
      if (!entry.isArchived && !entry.isDeleted) {
        final key = '${entry.date.year}-${entry.date.month}-${entry.date.day}';
        entryMap.putIfAbsent(key, () => []).add(entry);
      }
    }

    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Month Selector Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _previousMonth,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.getChipColor(brightness),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left, size: 18),
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: safeGoogleFont(
                    'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getHeadingColor(brightness),
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.getChipColor(brightness),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekdays Abbreviations
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdays.map((day) {
                return SizedBox(
                  width: 38,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: safeGoogleFont(
                      'Space Mono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getFaintColor(brightness),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Day Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1.35,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final date = cells[index];
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final isSelected =
                    date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                final key = '${date.year}-${date.month}-${date.day}';
                final dayEntries = entryMap[key] ?? [];
                final hasEntries = dayEntries.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected
                          ? AppTheme.getAccentGradient(palette)
                          : null,
                      color: !isSelected && isToday
                          ? AppTheme.getSoftBg(palette)
                          : Colors.transparent,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 14,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? AppTheme.getPrimaryColor(palette)
                                : AppTheme.getHeadingColor(brightness),
                          ),
                        ),
                        if (hasEntries && !isSelected)
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: AppTheme.getPrimaryColor(palette),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDayState(Color headingColor, Color bodyColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🗓️', style: TextStyle(fontSize: 38)),
            const SizedBox(height: 12),
            Text(
              'A blank page',
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No reflections written for this date yet.',
              textAlign: TextAlign.center,
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 13,
                color: bodyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
