import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';

class DiarySearchDelegate extends SearchDelegate {
  final List<DiaryEntry> entries;

  DiarySearchDelegate(this.entries);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = entries.where((entry) {
      final searchLower = query.toLowerCase();
      return entry.title.toLowerCase().contains(searchLower) ||
          entry.content.toLowerCase().contains(searchLower) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No matches found for "$query"',
          style: safeGoogleFont('Inter', color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return EntryCard(entry: results[index]);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = entries.where((entry) {
      final searchLower = query.toLowerCase();
      return entry.title.toLowerCase().contains(searchLower) ||
          entry.content.toLowerCase().contains(searchLower) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final entry = suggestions[index];
        return ListTile(
          title: Text(entry.title),
          subtitle: Text(
            entry.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Text(entry.mood, style: const TextStyle(fontSize: 24)),
          onTap: () {
            query = entry.title;
            showResults(context);
          },
        );
      },
    );
  }
}
