import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../helpers/font_helper.dart';
import 'timeline_screen.dart'; // To reuse DiagonalStripesPainter

class EntryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;
  final ThemeService themeService;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.themeService,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  static Route<void> route({
    required DiaryEntry entry,
    required ThemeService themeService,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    required VoidCallback onArchive,
  }) {
    return MaterialPageRoute(
      builder: (context) => EntryDetailScreen(
        entry: entry,
        themeService: themeService,
        onEdit: onEdit,
        onDelete: onDelete,
        onArchive: onArchive,
      ),
    );
  }

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
        return AppTheme.getPrimaryColor(themeService.themePalette);
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

  String _getMoodLabel(String mood) {
    switch (mood) {
      case '😊':
        return 'Happy';
      case '😌':
        return 'Calm';
      case '😍':
        return 'Awed';
      case '😔':
        return 'Down';
      case '😴':
        return 'Tired';
      case '🥳':
        return 'Proud';
      default:
        return 'Good';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final palette = themeService.themePalette;

    final bgGradient = AppTheme.getScreenBackground(brightness, palette);
    final cardBg = AppTheme.getCardBackground(brightness, palette);
    final headingColor = AppTheme.getHeadingColor(brightness);
    final bodyColor = AppTheme.getBodyColor(brightness);
    final faintColor = AppTheme.getFaintColor(brightness);

    final showPhoto = entry.imageUrls.isNotEmpty;

    return Scaffold(
      backgroundColor: bgGradient.colors.first,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cardBg,
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
                          child: Icon(Icons.arrow_back_ios_new, size: 16),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: cardBg,
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
                          child: Text('✏️', style: TextStyle(fontSize: 15)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detail Scroll View
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo Header / Category Badge Container
                      if (showPhoto)
                        Container(
                          height: 210,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
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
                              // Floating category emoji
                              Positioned(
                                top: 16,
                                left: 16,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(18),
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
                                      style: const TextStyle(fontSize: 27),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 14,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    entry.imageUrls.first,
                                    style: safeGoogleFont(
                                      'Space Mono',
                                      fontSize: 10,
                                      color: faintColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          height: 120,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE0F7),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              entry.mood,
                              style: const TextStyle(fontSize: 46),
                            ),
                          ),
                        ),

                      // Meta row
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              'EEEE, MMM d · HH:mm',
                            ).format(entry.date),
                            style: safeGoogleFont(
                              'Quicksand',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: faintColor,
                            ),
                          ),
                          const Spacer(),
                          if (entry.tags.isNotEmpty) ...[
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
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  entry.mood,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getMoodLabel(entry.mood),
                                  style: safeGoogleFont(
                                    'Quicksand',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.getMutedColor(brightness),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        entry.title,
                        style: safeGoogleFont(
                          'Quicksand',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Location row
                      if (entry.location != null &&
                          entry.location!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text('📍', style: TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              entry.location!,
                              style: safeGoogleFont(
                                'Quicksand',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: faintColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Content Body
                      Text(
                        entry.content,
                        style: safeGoogleFont(
                          'Quicksand',
                          fontSize: 15,
                          color: bodyColor,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onArchive();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getSoftBg(palette),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    entry.isArchived ? 'Unarchive' : 'Archive',
                                    style: safeGoogleFont(
                                      'Quicksand',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getPrimaryColor(palette),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                onDelete();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE9F0),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Delete',
                                    style: safeGoogleFont(
                                      'Quicksand',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFC25A7A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
