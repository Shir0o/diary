import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';

class ArchiveScreen extends StatelessWidget {
  final List<DiaryEntry> archivedEntries;
  final List<DiaryEntry> deletedEntries;
  final VoidCallback onMenuPressed;
  final ValueChanged<String> onRestoreEntry;
  final ValueChanged<String> onPermanentlyDeleteEntry;

  const ArchiveScreen({
    super.key,
    required this.archivedEntries,
    required this.deletedEntries,
    required this.onMenuPressed,
    required this.onRestoreEntry,
    required this.onPermanentlyDeleteEntry,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Archive & Trash',
            style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: onMenuPressed,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Archived'),
              Tab(text: 'Trash'),
            ],
            labelColor: Color(0xFF6751a4),
            indicatorColor: Color(0xFF6751a4),
          ),
        ),
        body: TabBarView(
          children: [
            _EntryList(
              entries: archivedEntries,
              emptyMessage: 'No archived entries',
              actionIcon: Icons.unarchive,
              actionLabel: 'Restore',
              onAction: onRestoreEntry,
            ),
            _EntryList(
              entries: deletedEntries,
              emptyMessage: 'Trash is empty',
              actionIcon: Icons.restore_from_trash,
              actionLabel: 'Restore',
              onAction: onRestoreEntry,
              secondaryActionIcon: Icons.delete_forever,
              secondaryActionLabel: 'Delete Forever',
              onSecondaryAction: onPermanentlyDeleteEntry,
            ),
          ],
        ),
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
  final IconData? secondaryActionIcon;
  final String? secondaryActionLabel;
  final ValueChanged<String>? onSecondaryAction;

  const _EntryList({
    required this.entries,
    required this.emptyMessage,
    required this.actionIcon,
    required this.actionLabel,
    required this.onAction,
    this.secondaryActionIcon,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: safeGoogleFont('Inter', color: Colors.grey),
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
                      icon: Icon(actionIcon, size: 18),
                      label: Text(actionLabel),
                    ),
                    if (secondaryActionIcon != null &&
                        onSecondaryAction != null)
                      TextButton.icon(
                        onPressed: () => _confirmPermanentDelete(context, entry),
                        icon: Icon(
                          secondaryActionIcon,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: Text(
                          secondaryActionLabel!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmPermanentDelete(BuildContext context, DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete permanently?'),
          content: const Text(
            'This action cannot be undone. The entry will be gone forever.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete Forever',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onSecondaryAction?.call(entry.id);
    }
  }
}
