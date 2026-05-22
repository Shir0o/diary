import 'package:flutter/material.dart';

import '../helpers/font_helper.dart';
import '../widgets/skeleton_loader.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<InfoSection> sections;
  final VoidCallback onBackPressed;
  final bool isLoading;

  const InfoScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.sections,
    required this.onBackPressed,
    this.isLoading = false,
  });

  factory InfoScreen.help({
    required VoidCallback onBackPressed,
    bool isLoading = false,
  }) {
    return InfoScreen(
      title: 'Help',
      icon: Icons.help_outline,
      onBackPressed: onBackPressed,
      isLoading: isLoading,
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
              'All diary entries are stored locally on this device in a secure SQLite database. The developers have no server backend and zero access to your database or files. Cloud backup controls and Google Drive sync options can be managed in Settings.',
        ),
        InfoSection(
          title: 'Security and biometrics',
          body:
              'To prevent unauthorized access, you can enable Biometric Lock in Settings. Authentication is handled entirely on-device by your operating system\'s secure biometric API (Face ID, Touch ID, or fingerprint lock), ensuring your data remains private and local.',
        ),
      ],
    );
  }

  factory InfoScreen.about({
    required VoidCallback onBackPressed,
    bool isLoading = false,
  }) {
    return InfoScreen(
      title: 'About',
      icon: Icons.info_outline,
      onBackPressed: onBackPressed,
      isLoading: isLoading,
      sections: const [
        InfoSection(
          title: 'Diary',
          body:
              'A private journal for writing, reviewing, and reflecting on personal entries.',
        ),
        InfoSection(title: 'Version', body: '0.1.0'),
        InfoSection(
          title: 'Privacy Declaration',
          body:
              'We believe your thoughts should remain yours. The Diary app is built on privacy-first principles:\n\n'
              '• No tracking, analytics, or external ads.\n'
              '• Full offline functionality: no account is required and no remote servers are used.\n'
              '• Google Drive synchronization is entirely optional, secure, and direct—meaning data is transferred directly between your device and your personal Google Drive app directory.',
        ),
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
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: onBackPressed,
        ),
      ),
      body: isLoading
          ? const InfoScreenSkeleton()
          : ListView(
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
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
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
