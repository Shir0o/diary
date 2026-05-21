import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
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
                Theme(
                  data: theme.copyWith(
                    colorScheme: colorScheme.copyWith(
                      onSurface: colorScheme.onSurface,
                    ),
                  ),
                  child: CalendarDatePicker(
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    onDateChanged: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                ),
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
}
