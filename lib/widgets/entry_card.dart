import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../helpers/font_helper.dart';
import '../config/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      margin: margin,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('h:mm a').format(entry.date),
                    style: safeGoogleFont(
                      'Inter',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trailing != null) ...[
                        trailing!,
                        const SizedBox(width: 8),
                      ],
                      Text(entry.mood, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              Text(
                entry.title,
                style: safeGoogleFont(
                  'Inter',
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppTheme.spacingExtraSmall),
              Text(
                entry.content,
                style: safeGoogleFont(
                  'Inter',
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              if (entry.imageUrls.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: entry.imageUrls.length == 1 ? 200 : 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                          child: Image.file(
                            File(entry.imageUrls[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Wrap(
                  spacing: AppTheme.spacingExtraSmall,
                  runSpacing: AppTheme.spacingExtraSmall,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSmall,
                        vertical: AppTheme.spacingExtraSmall / 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusMedium,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style:
                            (Theme.of(context).textTheme.labelSmall ??
                                    const TextStyle())
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (entry.location != null) ...[
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.location!,
                      style: safeGoogleFont(
                        'Inter',
                        color: colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
