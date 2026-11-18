import 'dart:math' as math;

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
                  children: [
                    IconButton(
                      onPressed: widget.onBackPressed,
                      tooltip: 'Back',
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Calendar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: safeGoogleFont(
                          'Quicksand',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onSearchEntries,
                      tooltip: 'Search entries',
                      icon: const ExcludeSemantics(
                        child: Text('🔍', style: TextStyle(fontSize: 16)),
                      ),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(38, 38),
                        padding: EdgeInsets.zero,
                        backgroundColor: AppTheme.getCardBackground(
                          brightness,
                          palette,
                        ),
                        tapTargetSize: MaterialTapTargetSize.padded,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Body
              Expanded(
                child: widget.isLoading
                    ? const CalendarScreenSkeleton()
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
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
                                _buildCustomCalendar(brightness, palette),
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
                                        color: AppTheme.getFaintColor(
                                          brightness,
                                        ),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_filteredEntries.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              // Lifts the empty state clear of the floating tab
                              // bar that DiaryApp overlays on the body.
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 100),
                                child: _buildEmptyDayState(
                                  headingColor,
                                  bodyColor,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                4,
                                24,
                                100,
                              ),
                              sliver: SliverList.builder(
                                itemCount: _filteredEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = _filteredEntries[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
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

  Widget _buildMonthStepButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required Brightness brightness,
  }) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        fixedSize: const Size(32, 32),
        padding: EdgeInsets.zero,
        backgroundColor: AppTheme.getChipColor(brightness),
        tapTargetSize: MaterialTapTargetSize.padded,
        shape: const CircleBorder(),
      ),
    );
  }

  /// [AppTheme.getAccentGradient]'s two stops, deepened. The raw accent is
  /// built to glow, which leaves white numerals at roughly 3.7:1; keeping the
  /// same hues dark enough lifts the selected day past WCAG AA.
  Gradient _selectedDayGradient(String palette) {
    Color deepen(Color color) => Color.lerp(color, Colors.black, 0.28)!;

    return LinearGradient(
      colors: [
        deepen(AppTheme.getPrimaryColor(palette)),
        deepen(AppTheme.getSecondaryColor(palette)),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool isSelected,
    required bool isToday,
    required int entryCount,
    required Brightness brightness,
    required String palette,
  }) {
    final isDark = brightness == Brightness.dark;
    final primary = AppTheme.getPrimaryColor(palette);
    final hasEntries = entryCount > 0;
    final readableDate = DateFormat('EEEE, MMMM d, yyyy').format(date);

    final Color ink;
    if (isSelected) {
      ink = Colors.white;
    } else if (!isToday) {
      ink = AppTheme.getHeadingColor(brightness);
    } else {
      // Neither the raw accent nor the heading clears AA on both today fills,
      // so today's ink moves towards the theme's extreme on each side.
      ink = isDark
          ? Color.lerp(primary, Colors.white, 0.55)!
          : Color.lerp(primary, Colors.black, 0.45)!;
    }

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: isSelected,
        hint: hasEntries
            ? '$readableDate, $entryCount '
                  '${entryCount == 1 ? 'entry' : 'entries'}'
            : readableDate,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected ? _selectedDayGradient(palette) : null,
              color: isSelected
                  ? null
                  : isToday
                  ? (isDark
                        ? primary.withValues(alpha: 0.24)
                        : AppTheme.getSoftBg(palette))
                  : null,
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
                    color: ink,
                  ),
                ),
                if (hasEntries && !isSelected)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isToday ? ink : primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

    // Every day cell keeps at least the 48dp Android tap target and grows with
    // the text scale so a large numeral plus its entry dot always fit. The week
    // shares the card's full width so all seven columns stay visible without a
    // horizontal scroll: at 390dp the card leaves each column ~49.7dp.
    const columns = 7;
    final dayCellExtent = math.max(
      48.0,
      MediaQuery.textScalerOf(context).scale(14) + 34.0,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Selector Header
          Row(
            children: [
              _buildMonthStepButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous month',
                onPressed: _previousMonth,
                brightness: brightness,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: safeGoogleFont(
                    'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getHeadingColor(brightness),
                  ),
                ),
              ),
              _buildMonthStepButton(
                icon: Icons.chevron_right,
                tooltip: 'Next month',
                onPressed: _nextMonth,
                brightness: brightness,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Weekdays Abbreviations
          Row(
            children: [
              for (final weekday in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: safeGoogleFont(
                        'Space Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getFaintColor(brightness),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Day Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 2,
              mainAxisExtent: dayCellExtent,
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

              return _buildDayCell(
                date: date,
                isSelected: isSelected,
                isToday: isToday,
                entryCount: dayEntries.length,
                brightness: brightness,
                palette: palette,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDayState(Color headingColor, Color bodyColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
