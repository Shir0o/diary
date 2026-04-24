import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/timeline_node.dart';
import '../widgets/entry_card.dart';
import 'new_entry_screen.dart';
import '../helpers/font_helper.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final List<DiaryEntry> _entries = [
    DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project. It\'s going to be a great journey of building something meaningful.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee while thinking about the UI design.',
      mood: '☕',
      location: 'Local Cafe',
    ),
    DiaryEntry(
      id: '3',
      date: DateTime.now().subtract(const Duration(days: 1)),
      title: 'Planning phase',
      content: 'Spent the day planning the features and architecture.',
      mood: '📝',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Diary',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final isFirst = index == 0;
          final isLast = index == _entries.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TimelineNode(
                  isFirst: isFirst,
                  isLast: isLast,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFirst || _isNewDay(index))
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                          child: Text(
                            _formatDate(entry.date),
                            style: safeGoogleFont(
                              'Inter',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      EntryCard(entry: entry),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NewEntryScreen()),
          );
        },
        backgroundColor: const Color(0xFF6751a4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  bool _isNewDay(int index) {
    if (index == 0) return true;
    final current = _entries[index].date;
    final previous = _entries[index - 1].date;
    return current.day != previous.day ||
        current.month != previous.month ||
        current.year != previous.year;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
