import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';

class TrashScreen extends StatelessWidget {
  final List<DiaryEntry> deletedEntries;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onRestoreEntry;
  final ValueChanged<String> onPermanentlyDeleteEntry;
  final bool isLoading;

  const TrashScreen({
    super.key,
    required this.deletedEntries,
    required this.onBackPressed,
    required this.onRestoreEntry,
    required this.onPermanentlyDeleteEntry,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Trash',
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
      body: isLoading
          ? const EntryListSkeleton()
          : _EntryList(
              entries: deletedEntries,
              emptyMessage: 'Trash is empty',
              actionIcon: Icons.restore_from_trash,
              actionLabel: 'Restore',
              onAction: onRestoreEntry,
              secondaryActionIcon: Icons.delete_forever,
              secondaryActionLabel: 'Delete Forever',
              onSecondaryAction: onPermanentlyDeleteEntry,
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
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                      if (secondaryActionIcon != null &&
                          onSecondaryAction != null)
                        TextButton.icon(
                          onPressed: () =>
                              _confirmPermanentDelete(context, entry),
                          icon: Icon(
                            secondaryActionIcon,
                            size: 18,
                            color: colorScheme.error,
                          ),
                          label: Text(
                            secondaryActionLabel!,
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Divider(color: colorScheme.outline.withValues(alpha: 0.1)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmPermanentDelete(
    BuildContext context,
    DiaryEntry entry,
  ) async {
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
              child: Text(
                'Delete Forever',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
