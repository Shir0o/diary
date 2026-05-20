import 'package:flutter/material.dart';

import '../helpers/font_helper.dart';
import '../models/diary_entry.dart';

class MediaScreen extends StatelessWidget {
  final List<DiaryEntry> entries;
  final VoidCallback onBackPressed;

  const MediaScreen({
    super.key,
    required this.entries,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final mediaItems = [
      for (final entry in entries)
        for (final imageUrl in entry.imageUrls)
          _MediaItem(entry: entry, imageUrl: imageUrl),
    ];

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Media',
          style: safeGoogleFont(
            'Inter',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: onBackPressed,
        ),
      ),
      body: mediaItems.isEmpty
          ? _EmptyMediaState(entryCount: entries.length)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: mediaItems.length,
              itemBuilder: (context, index) {
                final item = mediaItems[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text(
                        item.entry.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    child: Image.network(item.imageUrl, fit: BoxFit.cover),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyMediaState extends StatelessWidget {
  final int entryCount;

  const _EmptyMediaState({required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 56,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No media yet',
              style: safeGoogleFont(
                'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entryCount == 0
                  ? 'Create an entry and attach images to build your media library.'
                  : 'Your entries do not have image attachments yet.',
              textAlign: TextAlign.center,
              style: safeGoogleFont(
                'Inter',
                fontSize: 14,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaItem {
  final DiaryEntry entry;
  final String imageUrl;

  const _MediaItem({required this.entry, required this.imageUrl});
}
