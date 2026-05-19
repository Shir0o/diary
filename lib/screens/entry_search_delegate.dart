import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';

class EntrySearchDelegate extends SearchDelegate<DiaryEntry?> {
  final List<DiaryEntry> entries;

  EntrySearchDelegate(this.entries);

  @override
  String get searchFieldLabel => 'Search diary entries';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
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

  Widget _buildEntryList(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = normalizedQuery.isEmpty
        ? entries
        : entries.where((entry) {
            return entry.title.toLowerCase().contains(normalizedQuery) ||
                entry.content.toLowerCase().contains(normalizedQuery) ||
                (entry.location?.toLowerCase().contains(normalizedQuery) ??
                    false) ||
                entry.mood.contains(query.trim()) ||
                entry.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
          }).toList();

    final colorScheme = Theme.of(context).colorScheme;
    final subtleColor = colorScheme.onSurface.withValues(alpha: 0.6);

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No matching entries',
          style: safeGoogleFont('Inter', color: subtleColor),
        ),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = results[index];
        return ListTile(
          leading: Text(entry.mood, style: const TextStyle(fontSize: 22)),
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
    );
  }
}
