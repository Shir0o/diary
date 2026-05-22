import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/entry_card.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';
import '../config/app_theme.dart';

class ArchiveScreen extends StatelessWidget {
  final List<DiaryEntry> archivedEntries;
  final VoidCallback onBackPressed;
  final ValueChanged<String> onUnarchiveEntry;
  final ValueChanged<String> onDeleteEntry;
  final bool isLoading;

  const ArchiveScreen({
    super.key,
    required this.archivedEntries,
    required this.onBackPressed,
    required this.onUnarchiveEntry,
    required this.onDeleteEntry,
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
      body: isLoading
          ? const EntryListSkeleton()
          : Column(
              children: [
                _buildListHeader(
                  context,
                  '${archivedEntries.length} archived entries',
                  subtitle: 'Swipe right to restore, swipe left to trash.',
                ),
                Expanded(
                  child: _EntryList(
                    entries: archivedEntries,
                    emptyMessage: 'No archived entries',
                    actionLeftToRight: _ListAction.restore,
                    actionRightToLeft: _ListAction.delete,
                    onAction: (id, action) {
                      if (action == _ListAction.restore) {
                        onUnarchiveEntry(id);
                      } else if (action == _ListAction.delete) {
                        onDeleteEntry(id);
                      }
                    },
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
        ],
      ),
    );
  }
}

enum _ListAction { restore, delete }

class _EntryList extends StatelessWidget {
  final List<DiaryEntry> entries;
  final String emptyMessage;
  final _ListAction actionLeftToRight;
  final _ListAction actionRightToLeft;
  final void Function(String id, _ListAction action) onAction;

  const _EntryList({
    required this.entries,
    required this.emptyMessage,
    required this.actionLeftToRight,
    required this.actionRightToLeft,
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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Dismissible(
            key: Key('archive_dismissible_${entry.id}'),
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
              final action = direction == DismissDirection.startToEnd
                  ? actionLeftToRight
                  : actionRightToLeft;

              onAction(entry.id, action);
              return true;
            },
            child: EntryCard(
              entry: entry,
              margin: EdgeInsets.zero,
              onTap: null,
            ),
          ),
        );
      },
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
        iconData = Icons.unarchive;
        label = 'Restore';
        break;
      case _ListAction.delete:
        bgColor = AppTheme.warningColor;
        iconData = Icons.delete;
        label = 'Trash';
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
}
