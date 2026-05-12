import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/diary_search_delegate.dart';
import '../helpers/font_helper.dart';
import '../providers/diary_provider.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? initialDate;
  final List<DiaryEntry>? entries;
  const CalendarScreen({super.key, this.initialDate, this.entries});

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

  List<DiaryEntry> _filteredEntries(List<DiaryEntry> entries) {
    return entries.where((entry) {
      return entry.date.year == _selectedDate.year &&
          entry.date.month == _selectedDate.month &&
          entry.date.day == _selectedDate.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<DiaryEntry> entries;
    bool isLoading = false;

    if (widget.entries != null) {
      entries = widget.entries!;
    } else {
      final diaryProvider = Provider.of<DiaryProvider>(context);
      entries = diaryProvider.entries;
      isLoading = diaryProvider.isLoading;
    }

    final filteredEntries = _filteredEntries(entries);

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
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DiarySearchDelegate(entries),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                  child: filteredEntries.isEmpty
                      ? Center(
                          child: Text(
                            'No entries for this day',
                            style: safeGoogleFont('Inter', color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredEntries.length,
                          itemBuilder: (context, index) {
                            return EntryCard(entry: filteredEntries[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
