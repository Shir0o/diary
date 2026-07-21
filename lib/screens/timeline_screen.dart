import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';

class TimelineScreen extends StatefulWidget {
  final ThemeService? themeService;
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
    this.themeService,
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
      id: 'launch',
      date: DateTime.now(),
      title: 'Launch day, finally 🎉',
      content:
          'Shipped the release after weeks of heads-down work. The team celebrated quietly over coffee.',
      mood: '🚀',
      location: 'Home Office',
      tags: ['work'],
      imageUrls: ['photo.jpg'],
    ),
    DiaryEntry(
      id: 'evening',
      date: DateTime.now().subtract(const Duration(days: 1)),
      title: 'A quiet evening in 🌧️',
      content:
          'Read a few chapters of that sci-fi novel and made herbal tea. Rain against the window all night.',
      mood: '📖',
      tags: ['reading'],
    ),
    DiaryEntry(
      id: 'coffee',
      date: DateTime.now().subtract(const Duration(days: 4)),
      title: 'Coffee with Sarah ☕',
      content: 'Two hours flew by talking about the trip.',
      mood: '☕',
      location: 'Blue Bottle',
      tags: ['friends'],
    ),
    DiaryEntry(
      id: 'hike',
      date: DateTime.now().subtract(const Duration(days: 6)),
      title: 'Sunrise hike ⛰️',
      content: 'Up before dawn for the ridge trail.',
      mood: '⛰️',
      location: 'Eagle Ridge',
      tags: ['outdoors'],
      imageUrls: ['photo.jpg'],
    ),
  ];

  List<DiaryEntry> get _entries => widget.entries ?? _defaultEntries;

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return const Color(0xFF7A63C9);
      case 'reading':
        return const Color(0xFFB06CA6);
      case 'friends':
        return const Color(0xFFA86BC9);
      case 'outdoors':
        return const Color(0xFF6B9C5A);
      case 'travel':
        return const Color(0xFFC78B3C);
      default:
        return AppTheme.getPrimaryColor(
          widget.themeService?.themePalette ?? 'lilac',
        );
    }
  }

  Color _getTagBg(String tag) {
    switch (tag.toLowerCase()) {
      case 'work':
        return const Color(0xFFEFE9FF);
      case 'reading':
        return const Color(0xFFFBE9F6);
      case 'friends':
        return const Color(0xFFF3E9FB);
      case 'outdoors':
        return const Color(0xFFE6F2E2);
      case 'travel':
        return const Color(0xFFF6EDDC);
      default:
        return const Color(0xFFEFE9FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    String palette = 'lilac';
    try {
      palette = widget.themeService?.themePalette ?? 'lilac';
    } catch (_) {}

    String layout = 'playful';
    try {
      layout = widget.themeService?.timelineLayout ?? 'playful';
    } catch (_) {}

    final bgGradient = AppTheme.getScreenBackground(brightness, palette);
    final headingColor = AppTheme.getHeadingColor(brightness);
    final bodyColor = AppTheme.getBodyColor(brightness);

    return Scaffold(
      backgroundColor: bgGradient.colors.first,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 0, height: 0, child: Text('Diary')),
              // Custom Redesigned Timeline Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, ${widget.themeService?.userName ?? 'User'} 👋',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.getMutedColor(brightness),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Your day',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.onMenuPressed != null)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: widget.onMenuPressed,
                          ),
                        GestureDetector(
                          onTap: widget.onSearchEntries,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppTheme.getCardBackground(
                                brightness,
                                palette,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🔍', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFC9B8FF), Color(0xFFFFC9DE)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('🌷', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Timeline Content
              Expanded(
                child: widget.isLoading
                    ? const TimelineScreenSkeleton()
                    : RefreshIndicator(
                        onRefresh: widget.onRefresh ?? () async {},
                        child: _entries.isEmpty
                            ? _buildEmptyState(context, headingColor, bodyColor)
                            : _buildTimelineLayout(layout, brightness, palette),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineLayout(
    String layout,
    Brightness brightness,
    String palette,
  ) {
    switch (layout) {
      case 'compact':
        return _buildCompactTimeline(brightness, palette);
      case 'hero':
        return _buildHeroTimeline(brightness, palette);
      case 'feed':
        return _buildFeedTimeline(brightness, palette);
      case 'playful':
      default:
        return _buildPlayfulTimeline(brightness, palette);
    }
  }

  // --- 1. PLAYFUL TIMELINE ---
  Widget _buildPlayfulTimeline(Brightness brightness, String palette) {
    final lineC = AppTheme.getDottedLineColor(brightness);

    return Stack(
      children: [
        Positioned(
          left: 46,
          top: 0,
          bottom: 0,
          child: CustomPaint(
            size: const Size(2, double.infinity),
            painter: DottedLinePainter(color: lineC),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: 100,
            top: 12,
          ),
          itemCount: _entries.length,
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.horizontal,
              background: _buildSwipeBg(
                Alignment.centerLeft,
                Colors.amber,
                Icons.archive,
              ),
              secondaryBackground: _buildSwipeBg(
                Alignment.centerRight,
                Colors.red,
                Icons.delete,
              ),
              onDismissed: (direction) => _handleSwipe(entry, direction),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Playful Category Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getCategoryIconBg(entry.mood),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          entry.mood,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Entry Card
                    Expanded(
                      child: GestureDetector(
                        onTap: () => widget.onEditEntry?.call(entry),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.getCardBackground(
                              brightness,
                              palette,
                            ),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.getHairlineColor(brightness),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTimelineDate(entry.date),
                                    style: safeGoogleFont(
                                      'Quicksand',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getFaintColor(brightness),
                                    ),
                                  ),
                                  if (entry.tags.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTagBg(entry.tags.first),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '#${entry.tags.first}',
                                        style: safeGoogleFont(
                                          'Quicksand',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _getTagColor(entry.tags.first),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.title,
                                style: safeGoogleFont(
                                  'Quicksand',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getHeadingColor(brightness),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.content,
                                style: safeGoogleFont(
                                  'Quicksand',
                                  fontSize: 13.5,
                                  color: AppTheme.getBodyColor(brightness),
                                ),
                              ),
                              if (entry.imageUrls.isNotEmpty) ...[
                                const SizedBox(height: 11),
                                _buildPhotoPlaceholder(
                                  brightness,
                                  entry.imageUrls.first,
                                ),
                              ],
                              if (entry.location != null &&
                                  entry.location!.isNotEmpty) ...[
                                const SizedBox(height: 9),
                                Row(
                                  children: [
                                    Text(
                                      '📍',
                                      style: TextStyle(
                                        color: AppTheme.getFaintColor(
                                          brightness,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      entry.location!,
                                      style: safeGoogleFont(
                                        'Quicksand',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.getFaintColor(
                                          brightness,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- 2. COMPACT TIMELINE ---
  Widget _buildCompactTimeline(Brightness brightness, String palette) {
    final lineC = AppTheme.getDottedLineColor(brightness);
    final headingC = AppTheme.getHeadingColor(brightness);
    final mutedC = AppTheme.getMutedColor(brightness);

    // Group entries by date sections
    final Map<String, List<DiaryEntry>> grouped = {};
    for (var entry in _entries) {
      final key = _getDateSectionHeader(entry.date);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    final List<dynamic> listItems = [];
    grouped.forEach((section, entries) {
      listItems.add(section);
      listItems.addAll(entries);
    });

    return Stack(
      children: [
        Positioned(
          left: 40,
          top: 0,
          bottom: 0,
          child: CustomPaint(
            size: const Size(2, double.infinity),
            painter: DottedLinePainter(color: lineC),
          ),
        ),
        ListView.builder(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: 100,
            top: 12,
          ),
          itemCount: listItems.length,
          itemBuilder: (context, index) {
            final item = listItems[index];
            if (item is String) {
              return Padding(
                padding: const EdgeInsets.only(left: 30, top: 12, bottom: 6),
                child: Text(
                  item,
                  style: safeGoogleFont(
                    'Space Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getFaintColor(brightness),
                    letterSpacing: 1,
                  ),
                ),
              );
            }

            final entry = item as DiaryEntry;
            return Dismissible(
              key: Key(entry.id),
              direction: DismissDirection.horizontal,
              background: _buildSwipeBg(
                Alignment.centerLeft,
                Colors.amber,
                Icons.archive,
              ),
              secondaryBackground: _buildSwipeBg(
                Alignment.centerRight,
                Colors.red,
                Icons.delete,
              ),
              onDismissed: (direction) => _handleSwipe(entry, direction),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: GestureDetector(
                  onTap: () => widget.onEditEntry?.call(entry),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardBackground(brightness, palette),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.getHairlineColor(brightness),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Left emoji
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _getCategoryIconBg(entry.mood),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Text(
                              entry.mood,
                              style: const TextStyle(fontSize: 19),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: safeGoogleFont(
                                  'Quicksand',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: headingC,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('HH:mm').format(entry.date)}${entry.location != null ? ' · ${entry.location}' : ''}${entry.tags.isNotEmpty ? ' · #${entry.tags.first}' : ''}',
                                style: safeGoogleFont(
                                  'Quicksand',
                                  fontSize: 12,
                                  color: mutedC,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Right photo chip if attached
                        if (entry.imageUrls.isNotEmpty)
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(11),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: CustomPaint(
                              painter: DiagonalStripesPainter(
                                color1: const Color(0xFFE7E0F7),
                                color2: const Color(0xFFEFE9FB),
                                stripeWidth: 6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // --- 3. HERO TIMELINE ---
  Widget _buildHeroTimeline(Brightness brightness, String palette) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 22, right: 22, bottom: 100, top: 12),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isHero = index == 0;

        if (isHero) {
          // Large featured card
          return Dismissible(
            key: Key(entry.id),
            direction: DismissDirection.horizontal,
            background: _buildSwipeBg(
              Alignment.centerLeft,
              Colors.amber,
              Icons.archive,
            ),
            secondaryBackground: _buildSwipeBg(
              Alignment.centerRight,
              Colors.red,
              Icons.delete,
            ),
            onDismissed: (direction) => _handleSwipe(entry, direction),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => widget.onEditEntry?.call(entry),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getCardBackground(brightness, palette),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.getHairlineColor(brightness),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Photo Header
                      Container(
                        height: 184,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: DiagonalStripesPainter(
                                  color1: const Color(0xFFE7E0F7),
                                  color2: const Color(0xFFEFE9FB),
                                  stripeWidth: 10,
                                ),
                              ),
                            ),
                            // Floating emoji icon
                            Positioned(
                              top: 14,
                              left: 14,
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    entry.mood,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            ),
                            // photo.jpg label
                            if (entry.imageUrls.isNotEmpty)
                              Positioned(
                                bottom: 12,
                                left: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    entry.imageUrls.first,
                                    style: safeGoogleFont(
                                      'Space Mono',
                                      fontSize: 9.5,
                                      color: AppTheme.getFaintColor(brightness),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat('HH:mm').format(entry.date)}${entry.location != null ? ' · ${entry.location}' : ''}',
                                  style: safeGoogleFont(
                                    'Quicksand',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getFaintColor(brightness),
                                  ),
                                ),
                                if (entry.tags.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getTagBg(entry.tags.first),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '#${entry.tags.first}',
                                      style: safeGoogleFont(
                                        'Quicksand',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _getTagColor(entry.tags.first),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.title,
                              style: safeGoogleFont(
                                'Quicksand',
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getHeadingColor(brightness),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry.content,
                              style: safeGoogleFont(
                                'Quicksand',
                                fontSize: 14.5,
                                color: AppTheme.getBodyColor(brightness),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Standard card preview
        return Dismissible(
          key: Key(entry.id),
          direction: DismissDirection.horizontal,
          background: _buildSwipeBg(
            Alignment.centerLeft,
            Colors.amber,
            Icons.archive,
          ),
          secondaryBackground: _buildSwipeBg(
            Alignment.centerRight,
            Colors.red,
            Icons.delete,
          ),
          onDismissed: (direction) => _handleSwipe(entry, direction),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: GestureDetector(
              onTap: () => widget.onEditEntry?.call(entry),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getCategoryIconBg(entry.mood),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        entry.mood,
                        style: const TextStyle(fontSize: 21),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getHeadingColor(brightness),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_formatTimelineDate(entry.date)} · ${DateFormat('HH:mm').format(entry.date)}${entry.tags.isNotEmpty ? ' · #${entry.tags.first}' : ''}',
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 12.5,
                            color: AppTheme.getMutedColor(brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.getFaintColor(brightness),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 4. FEED TIMELINE ---
  Widget _buildFeedTimeline(Brightness brightness, String palette) {
    // 2-column Layout
    final leftCol = <DiaryEntry>[];
    final rightCol = <DiaryEntry>[];

    for (int i = 0; i < _entries.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(_entries[i]);
      } else {
        rightCol.add(_entries[i]);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 100, top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: leftCol
                  .map((e) => _buildFeedCard(brightness, palette, e, true))
                  .toList(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 22),
                ...rightCol.map(
                  (e) => _buildFeedCard(brightness, palette, e, false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(
    Brightness brightness,
    String palette,
    DiaryEntry entry,
    bool isLeft,
  ) {
    final showImage = entry.imageUrls.isNotEmpty;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBg(
        Alignment.centerLeft,
        Colors.amber,
        Icons.archive,
      ),
      secondaryBackground: _buildSwipeBg(
        Alignment.centerRight,
        Colors.red,
        Icons.delete,
      ),
      onDismissed: (direction) => _handleSwipe(entry, direction),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.getCardBackground(brightness, palette),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: AppTheme.getHairlineColor(brightness)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: () => widget.onEditEntry?.call(entry),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showImage)
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DiagonalStripesPainter(
                            color1: const Color(0xFFE7E0F7),
                            color2: const Color(0xFFEFE9FB),
                            stripeWidth: 8,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              entry.mood,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showImage) ...[
                      Text(entry.mood, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      entry.title,
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getHeadingColor(brightness),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_formatTimelineDate(entry.date)}${entry.tags.isNotEmpty ? ' · #${entry.tags.first}' : ''}',
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 11.5,
                        color: AppTheme.getFaintColor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB WIDGETS & UTILS ---

  Widget _buildSwipeBg(Alignment alignment, Color color, IconData icon) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  void _handleSwipe(DiaryEntry entry, DismissDirection direction) {
    if (direction == DismissDirection.endToStart) {
      widget.onDeleteEntry?.call(entry.id);
    } else {
      widget.onArchiveEntry?.call(entry.id);
    }
  }

  Color _getCategoryIconBg(String emoji) {
    switch (emoji) {
      case '🚀':
        return const Color(0xFFDFF0E4);
      case '📖':
        return const Color(0xFFEDE0F7);
      case '☕':
        return const Color(0xFFFBEADF);
      case '⛰️':
        return const Color(0xFFE0EFDF);
      default:
        return const Color(0xFFF4F1FB);
    }
  }

  String _formatTimelineDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    }
    if (date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(date);
  }

  String _getDateSectionHeader(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'TODAY';
    }
    if (date.day == now.subtract(const Duration(days: 1)).day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'YESTERDAY';
    }
    return DateFormat('MMM d').format(date).toUpperCase();
  }

  Widget _buildPhotoPlaceholder(Brightness brightness, String name) {
    return Container(
      height: 104,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: DiagonalStripesPainter(
                color1: const Color(0xFFE7E0F7),
                color2: const Color(0xFFEFE9FB),
                stripeWidth: 8,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                name,
                style: safeGoogleFont(
                  'Space Mono',
                  fontSize: 9.5,
                  color: AppTheme.getFaintColor(brightness),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    Color headingColor,
    Color bodyColor,
  ) {
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
                  color:
                      (widget.themeService?.themePalette ?? 'lilac') == 'lilac'
                      ? const Color(0xFFEFE9FF)
                      : AppTheme.getPrimaryColor(
                          widget.themeService?.themePalette ?? 'lilac',
                        ).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '📝',
                    style: TextStyle(
                      fontSize: 48,
                      color: AppTheme.getPrimaryColor(
                        widget.themeService?.themePalette ?? 'lilac',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Diary is Empty',
                textAlign: TextAlign.center,
                style: safeGoogleFont(
                  'Quicksand',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capture your thoughts, mood, and daily reflections. Start your journey by writing your first entry.',
                textAlign: TextAlign.center,
                style: safeGoogleFont(
                  'Quicksand',
                  fontSize: 14,
                  color: bodyColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: widget.onAddEntry,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Write First Entry',
                  style: safeGoogleFont(
                    'Quicksand',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(
                    widget.themeService?.themePalette ?? 'lilac',
                  ),
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

// Custom Painters for styling
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedLinePainter({
    required this.color,
    this.strokeWidth = 3.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + gap),
        paint,
      );
      startY += gap * 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiagonalStripesPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double stripeWidth;

  DiagonalStripesPainter({
    required this.color1,
    required this.color2,
    this.stripeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background
    paint.color = color1;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw diagonal stripes
    paint.color = color2;
    final path = Path();

    final double step = stripeWidth * 2;
    for (double i = -size.height; i < size.width; i += step) {
      path.reset();
      path.moveTo(i, 0);
      path.lineTo(i + stripeWidth, 0);
      path.lineTo(i + stripeWidth + size.height, size.height);
      path.lineTo(i + size.height, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
