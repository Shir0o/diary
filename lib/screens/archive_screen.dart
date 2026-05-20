import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';

class ArchiveScreen extends StatelessWidget {
  final List<DiaryEntry> archivedEntries;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onUnarchiveEntry;

  const ArchiveScreen({
    super.key,
    required this.archivedEntries,
    required this.onBackPressed,
    required this.onUnarchiveEntry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Archive',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: onBackPressed,
        ),
      ),
      body: _EntryList(
        entries: archivedEntries,
        emptyMessage: 'No archived entries',
        actionIcon: Icons.unarchive,
        actionLabel: 'Unarchive',
        onAction: onUnarchiveEntry,
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final String emptyMessage;
  final IconData actionIcon;
  final String actionLabel;
  final ValueChanged<String> onAction;

  const _EntryList({
    required this.entries,
    required this.emptyMessage,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (entries.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: safeGoogleFont(
            'Inter',
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              EntryCard(entry: entry, onTap: null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onAction(entry.id),
                      icon: Icon(
                        actionIcon,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        actionLabel,
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
            ],
          ),
        );
      },
    );
  }
}
