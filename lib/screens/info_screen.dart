import 'package:flutter/material.dart';

import '../helpers/font_helper.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoSection> sections;
  final VoidCallback? onMenuPressed;

  const InfoScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.sections,
    this.onMenuPressed,
  });

  factory InfoScreen.help({VoidCallback? onMenuPressed}) {
    return InfoScreen(
      title: 'Help',
      icon: Icons.help_outline,
      onMenuPressed: onMenuPressed,
      sections: const [
        InfoSection(
          title: 'Writing entries',
          body:
              'Use the add button to write a new entry. Tap an existing entry to edit its text.',
        ),
        InfoSection(
          title: 'Reviewing your diary',
          body:
              'Timeline shows entries by date. Calendar filters entries by the selected day. Analytics summarizes entry count, streaks, mood, and weekly activity.',
        ),
        InfoSection(
          title: 'Backup and privacy',
          body:
              'Entries are stored locally on this device. Cloud backup controls are available in Settings.',
        ),
      ],
    );
  }

  factory InfoScreen.about({VoidCallback? onMenuPressed}) {
    return InfoScreen(
      title: 'About',
      icon: Icons.info_outline,
      onMenuPressed: onMenuPressed,
      sections: const [
        InfoSection(
          title: 'Diary',
          body:
              'A private journal for writing, reviewing, and reflecting on personal entries.',
        ),
        InfoSection(title: 'Version', body: '0.1.0'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          title,
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
          icon: Icon(Icons.menu, color: colorScheme.onSurface),
          onPressed: onMenuPressed,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(icon, size: 48, color: colorScheme.primary),
          const SizedBox(height: 16),
          for (final section in sections)
            Card(
              elevation: 0,
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: safeGoogleFont(
                        'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.body,
                      style: safeGoogleFont(
                        'Inter',
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class InfoSection {
  final String title;
  final String body;

  const InfoSection({required this.title, required this.body});
}
