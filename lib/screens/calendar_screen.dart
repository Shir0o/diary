import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? initialDate;
  final VoidCallback? onMenuPressed;
  final ValueChanged<DiaryEntry>? onEditEntry;
  final List<DiaryEntry>? entries;

  const CalendarScreen({
    super.key,
    this.initialDate,
    this.onMenuPressed,
    this.onEditEntry,
    this.entries,
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
      return entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed:
                widget.onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _filteredEntries.isEmpty
                ? Center(
                    child: Text(
                      'No entries for this day',
                      style: safeGoogleFont('Inter', color: Colors.grey),
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
