import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';

class EntrySearchDelegate extends SearchDelegate<DiaryEntry?> {
  final List<DiaryEntry> entries;

  String? _selectedMood;
  String? _selectedTag;
  DateTimeRange? _selectedDateRange;
  bool _hasImagesOnly = false;

  EntrySearchDelegate(this.entries);

  @override
  String get searchFieldLabel => 'Search diary entries';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty ||
          _selectedMood != null ||
          _selectedTag != null ||
          _selectedDateRange != null ||
          _hasImagesOnly)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _selectedMood = null;
            _selectedTag = null;
            _selectedDateRange = null;
            _hasImagesOnly = false;
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildEntryList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildEntryList(context);
  }

  Widget _buildFilterBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Extract all unique tags and moods
    final allTags = entries.expand((e) => e.tags).toSet().toList()..sort();
    final allMoods = entries.map((e) => e.mood).toSet().toList()..sort();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Mood Chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_selectedMood ?? 'Mood'),
              selected: _selectedMood != null,
              onSelected: (selected) async {
                if (!selected) {
                  _selectedMood = null;
                  showSuggestions(context);
                  return;
                }
                final mood = await _showMoodSelector(context, allMoods);
                if (mood != null) {
                  _selectedMood = mood;
                  // ignore: use_build_context_synchronously
                  showSuggestions(context);
                }
              },
            ),
          ),
          // Tag Chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_selectedTag != null ? '#$_selectedTag' : 'Tag'),
              selected: _selectedTag != null,
              onSelected: (selected) async {
                if (!selected) {
                  _selectedTag = null;
                  showSuggestions(context);
                  return;
                }
                final tag = await _showTagSelector(context, allTags);
                if (tag != null) {
                  _selectedTag = tag;
                  // ignore: use_build_context_synchronously
                  showSuggestions(context);
                }
              },
            ),
          ),
          // Date Range Chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                _selectedDateRange != null
                    ? '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}'
                    : 'Date Range',
              ),
              selected: _selectedDateRange != null,
              onSelected: (selected) async {
                if (!selected) {
                  _selectedDateRange = null;
                  showSuggestions(context);
                  return;
                }
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  initialDateRange: _selectedDateRange,
                );
                if (range != null) {
                  _selectedDateRange = range;
                  // ignore: use_build_context_synchronously
                  showSuggestions(context);
                }
              },
            ),
          ),
          // Media Chip
          FilterChip(
            label: const Text('Has Images'),
            selected: _hasImagesOnly,
            onSelected: (selected) {
              _hasImagesOnly = selected;
              showSuggestions(context);
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _showMoodSelector(BuildContext context, List<String> moods) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Select Mood',
                  style: safeGoogleFont(
                    'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (moods.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No moods found in entries'),
                )
              else
                GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  children: moods.map((mood) {
                    return InkWell(
                      onTap: () => Navigator.of(context).pop(mood),
                      borderRadius: BorderRadius.circular(8),
                      child: Center(
                        child: Text(mood, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showTagSelector(BuildContext context, List<String> tags) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  'Select Tag',
                  style: safeGoogleFont(
                    'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (tags.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tags found in entries'),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: tags.map((tag) {
                      return ListTile(
                        leading: const Icon(Icons.label_outlined),
                        title: Text('#$tag'),
                        onTap: () => Navigator.of(context).pop(tag),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntryList(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();

    final results = entries.where((entry) {
      // 1. Text Search query
      final matchesQuery =
          query.isEmpty ||
          entry.title.toLowerCase().contains(normalizedQuery) ||
          entry.content.toLowerCase().contains(normalizedQuery) ||
          (entry.location?.toLowerCase().contains(normalizedQuery) ?? false) ||
          entry.mood.contains(query.trim()) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));

      if (!matchesQuery) {
        return false;
      }

      // 2. Mood Filter
      if (_selectedMood != null && entry.mood != _selectedMood) {
        return false;
      }

      // 3. Tag Filter
      if (_selectedTag != null && !entry.tags.contains(_selectedTag)) {
        return false;
      }

      // 4. Date Range Filter
      if (_selectedDateRange != null) {
        final date = DateTime(
          entry.date.year,
          entry.date.month,
          entry.date.day,
        );
        if (date.isBefore(_selectedDateRange!.start) ||
            date.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }

      // 5. Media Filter
      if (_hasImagesOnly && entry.imageUrls.isEmpty) return false;

      return true;
    }).toList();

    final colorScheme = Theme.of(context).colorScheme;
    final subtleColor = colorScheme.onSurface.withValues(alpha: 0.6);

    return Column(
      children: [
        _buildFilterBar(context),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Text(
                    'No matching entries',
                    style: safeGoogleFont('Inter', color: subtleColor),
                  ),
                )
              : ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = results[index];
                    return ListTile(
                      leading: Text(
                        entry.mood,
                        style: const TextStyle(fontSize: 22),
                      ),
                      title: Text(
                        entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: safeGoogleFont(
                          'Inter',
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('MMM d, yyyy h:mm a').format(entry.date)}  ${entry.content}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: safeGoogleFont('Inter', color: subtleColor),
                      ),
                      onTap: () => close(context, entry),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
