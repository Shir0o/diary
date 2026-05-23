import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback onBackPressed;
  final VoidCallback? onSearchEntries;
  final ValueChanged<DiaryEntry>? onEditEntry;
  final List<DiaryEntry>? entries;
  final bool isLoading;

  const CalendarScreen({
    super.key,
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: widget.onBackPressed,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: widget.onSearchEntries,
          ),
        ],
      ),
      body: widget.isLoading
          ? const CalendarScreenSkeleton()
          : Column(
              children: [
                _buildCustomCalendar(context),
                Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _filteredEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No entries for this day',
                            style: safeGoogleFont(
                              'Inter',
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return EntryCard(
                              entry: entry,
                              onTap: widget.onEditEntry == null
                                  ? null
                                  : () => widget.onEditEntry!(entry),
                            );
                          },
                        ),
                ),
              ],
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

  Widget _buildCustomCalendar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final days = _daysInMonth(_currentMonth);
    final firstWeekday = _firstWeekdayOfMonth(_currentMonth);

    final List<DateTime?> cells = [];
    for (int i = 1; i < firstWeekday; i++) {
      cells.add(null);
    }
    for (int i = 1; i <= days; i++) {
      cells.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        // Month Selector Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_currentMonth),
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
            ],
          ),
        ),
        // Weekdays Abbreviations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) {
              return SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: safeGoogleFont(
                    'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Day Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final cell = cells[index];
              if (cell == null) return const SizedBox.shrink();

              final isSelected =
                  cell.year == _selectedDate.year &&
                  cell.month == _selectedDate.month &&
                  cell.day == _selectedDate.day;

              final today = DateTime.now();
              final isToday =
                  cell.year == today.year &&
                  cell.month == today.month &&
                  cell.day == today.day;

              final hasEntries = _entries.any((entry) {
                return !entry.isArchived &&
                    !entry.isDeleted &&
                    entry.date.year == cell.year &&
                    entry.date.month == cell.month &&
                    entry.date.day == cell.day;
              });

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = cell;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : isToday
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday && !isSelected
                        ? Border.all(color: colorScheme.primary, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cell.day.toString(),
                        style: safeGoogleFont(
                          'Inter',
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (hasEntries) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
