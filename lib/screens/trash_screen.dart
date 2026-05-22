import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';
import '../config/app_theme.dart';

class TrashScreen extends StatelessWidget {
  final List<DiaryEntry> deletedEntries;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onRestoreEntry;
  final ValueChanged<String> onPermanentlyDeleteEntry;
  final VoidCallback onEmptyTrash;
  final bool autoDeleteEnabled;
  final int retentionDays;
  final bool isLoading;

  const TrashScreen({
    super.key,
    required this.deletedEntries,
    required this.onBackPressed,
    required this.onRestoreEntry,
    required this.onPermanentlyDeleteEntry,
    required this.onEmptyTrash,
    required this.autoDeleteEnabled,
    required this.retentionDays,
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
          : Column(
              children: [
                _buildListHeader(
                  context,
                  '${deletedEntries.length} items in trash',
                  subtitle: autoDeleteEnabled
                      ? 'Items in Trash are permanently deleted after $retentionDays days.'
                      : 'Auto-delete is disabled.',
                  actionButton: deletedEntries.isNotEmpty
                      ? TextButton.icon(
                          onPressed: () => _confirmEmptyTrash(context),
                          icon: Icon(
                            Icons.delete_sweep,
                            color: colorScheme.error,
                          ),
                          label: Text(
                            'Empty',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: _EntryList(
                    entries: deletedEntries,
                    emptyMessage: 'Trash is empty',
                    actionLeftToRight: _ListAction.restore,
                    actionRightToLeft: _ListAction.deleteForever,
                    onAction: (id, action) {
                      if (action == _ListAction.restore) {
                        onRestoreEntry(id);
                      }
                    },
                    autoDeleteEnabled: autoDeleteEnabled,
                    retentionDays: retentionDays,
                    onPermanentlyDeleteEntry: onPermanentlyDeleteEntry,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildListHeader(
    BuildContext context,
    String title, {
    String? subtitle,
    Widget? actionButton,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: safeGoogleFont(
                    'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: safeGoogleFont(
                      'Inter',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionButton != null) ...[const SizedBox(width: 8), actionButton],
        ],
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Empty Trash?'),
          content: const Text(
            'All items in the trash will be permanently deleted. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Empty Trash',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      onEmptyTrash();
    }
  }
}

enum _ListAction { restore, deleteForever }

class _EntryList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final String emptyMessage;
  final _ListAction actionLeftToRight;
  final _ListAction actionRightToLeft;
  final void Function(String id, _ListAction action) onAction;
  final bool autoDeleteEnabled;
  final int retentionDays;
  final ValueChanged<String> onPermanentlyDeleteEntry;

  const _EntryList({
    required this.entries,
    required this.emptyMessage,
    required this.actionLeftToRight,
    required this.actionRightToLeft,
    required this.onAction,
    required this.autoDeleteEnabled,
    required this.retentionDays,
    required this.onPermanentlyDeleteEntry,
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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Dismissible(
            key: Key('trash_dismissible_${entry.id}'),
            direction: DismissDirection.horizontal,
            background: _buildDismissBackground(
              context,
              actionLeftToRight,
              true,
            ),
            secondaryBackground: _buildDismissBackground(
              context,
              actionRightToLeft,
              false,
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                onAction(entry.id, actionLeftToRight);
                return true;
              } else {
                final confirmed = await _confirmPermanentDelete(context, entry);
                if (confirmed) {
                  onPermanentlyDeleteEntry(entry.id);
                  return true;
                }
                return false;
              }
            },
            child: EntryCard(
              entry: entry,
              margin: EdgeInsets.zero,
              onTap: null,
              trailing: autoDeleteEnabled
                  ? _buildDaysRemainingBadge(context, entry)
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaysRemainingBadge(BuildContext context, DiaryEntry entry) {
    final deleteDate = entry.updatedAt.add(Duration(days: retentionDays));
    final daysLeft = deleteDate.difference(DateTime.now()).inDays;

    final String text = daysLeft <= 0 ? 'Deletes today' : '$daysLeft days left';
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: safeGoogleFont(
          'Inter',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: errorColor,
        ),
      ),
    );
  }

  Widget _buildDismissBackground(
    BuildContext context,
    _ListAction action,
    bool isLeft,
  ) {
    Color bgColor;
    IconData iconData;
    String label;

    switch (action) {
      case _ListAction.restore:
        bgColor = AppTheme.successColor;
        iconData = Icons.restore_from_trash;
        label = 'Restore';
        break;
      case _ListAction.deleteForever:
        bgColor = Theme.of(context).colorScheme.error;
        iconData = Icons.delete_forever;
        label = 'Delete';
        break;
    }

    return Container(
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(iconData, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmPermanentDelete(
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
    return confirmed ?? false;
  }
}
