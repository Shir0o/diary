import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../helpers/font_helper.dart';
import '../config/app_theme.dart';
import '../screens/timeline_screen.dart'; // To reuse DiagonalStripesPainter

class EntryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Widget? trailing;

  const EntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.trailing,
  });

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
        return const Color(0xFF8B6CFF);
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
    final cardBg = theme.cardColor;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(entry.date),
                      style: safeGoogleFont(
                        'Quicksand',
                        color: AppTheme.getFaintColor(brightness),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (trailing != null) ...[
                          trailing!,
                          const SizedBox(width: 8),
                        ],
                        if (entry.tags.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getTagBg(entry.tags.first),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#${entry.tags.first}',
                              style: safeGoogleFont(
                                'Quicksand',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getTagColor(entry.tags.first),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F1FB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              entry.mood,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  entry.title,
                  style: safeGoogleFont(
                    'Quicksand',
                    color: AppTheme.getHeadingColor(brightness),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.content,
                  style: safeGoogleFont(
                    'Quicksand',
                    color: AppTheme.getBodyColor(brightness),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.location != null && entry.location!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '📍',
                        style: TextStyle(
                          color: AppTheme.getFaintColor(brightness),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.location!,
                          style: safeGoogleFont(
                            'Quicksand',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getFaintColor(brightness),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (entry.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CustomPaint(
                      painter: DiagonalStripesPainter(
                        color1: const Color(0xFFE7E0F7),
                        color2: const Color(0xFFEFE9FB),
                        stripeWidth: 8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
