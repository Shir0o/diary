import 'package:flutter/material.dart';
import '../models/diary_entry.dart';
import '../widgets/timeline_node.dart';
import '../widgets/entry_card.dart';
import 'new_entry_screen.dart';
import '../helpers/font_helper.dart';
import '../config/app_theme.dart';
import '../widgets/skeleton_loader.dart';

class TimelineScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onAddEntry;
  final VoidCallback? onSearchEntries;
  final VoidCallback? onCalendarPressed;
  final ValueChanged<DiaryEntry>? onEditEntry;
  final ValueChanged<String>? onDeleteEntry;
  final ValueChanged<String>? onArchiveEntry;
  final List<DiaryEntry>? entries;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  const TimelineScreen({
    super.key,
    this.onMenuPressed,
    this.onAddEntry,
    this.onSearchEntries,
    this.onCalendarPressed,
    this.onEditEntry,
    this.onDeleteEntry,
    this.onArchiveEntry,
    this.entries,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  static final List<DiaryEntry> _defaultEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime.now(),
      title: 'Starting a new project',
      content:
          'Today I started the Diary app project. It\'s going to be a great journey of building something meaningful.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      title: 'Coffee Break',
      content:
          'Had a wonderful cup of coffee while thinking about the UI design.',
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

  List<DiaryEntry> get _entries => widget.entries ?? _defaultEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Diary',
          style: safeGoogleFont('Inter', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            onPressed:
                widget.onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: widget.onSearchEntries,
          ),
          IconButton(
            icon: Icon(Icons.calendar_month, color: colorScheme.onSurface),
            onPressed: widget.onCalendarPressed,
          ),
        ],
      ),
      body: widget.isLoading
          ? const TimelineScreenSkeleton()
          : RefreshIndicator(
              onRefresh: widget.onRefresh ?? () async {},
              child: _entries.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        final isFirst = index == 0;
                        final isLast = index == _entries.length - 1;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TimelineNode(isFirst: isFirst, isLast: isLast),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isFirst || _isNewDay(index))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 16,
                                          top: 16,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          _formatDate(entry.date),
                                          style: safeGoogleFont(
                                            'Inter',
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 16,
                                      ),
                                      child: Dismissible(
                                        key: Key(entry.id),
                                        direction: DismissDirection.horizontal,
                                        background: Container(
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.borderRadiusMedium,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.archive,
                                            color: Colors.white,
                                          ),
                                        ),
                                        secondaryBackground: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.borderRadiusMedium,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onDismissed: (direction) {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            widget.onDeleteEntry?.call(
                                              entry.id,
                                            );
                                          } else {
                                            widget.onArchiveEntry?.call(
                                              entry.id,
                                            );
                                          }
                                        },
                                        child: EntryCard(
                                          entry: entry,
                                          margin: EdgeInsets.zero,
                                          onTap: widget.onEditEntry == null
                                              ? null
                                              : () =>
                                                    widget.onEditEntry!(entry),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddEntry ?? _openNewEntry,
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.add, color: colorScheme.onPrimary),
      ),
    );
  }

  void _openNewEntry() {
    Navigator.of(context).push(NewEntryScreen.route());
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
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit_note_outlined,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              Text(
                'Your Diary is Empty',
                textAlign: TextAlign.center,
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                'Capture your thoughts, mood, and daily reflections. Start your journey by writing your first entry.',
                textAlign: TextAlign.center,
                style: safeGoogleFont(
                  'Inter',
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacingExtraLarge),
              ElevatedButton.icon(
                onPressed: widget.onAddEntry ?? _openNewEntry,
                icon: const Icon(Icons.add),
                label: const Text('Write First Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
