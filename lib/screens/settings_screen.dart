import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/font_helper.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricLock = false;
  bool _autoBackup = true;

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  if (val != null) themeProvider.setThemeMode(val);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  if (val != null) themeProvider.setThemeMode(val);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  if (val != null) themeProvider.setThemeMode(val);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFFEF7FF),
      appBar: AppBar(
        backgroundColor: isDark ? null : const Color(0xFFFEF7FF).withValues(alpha: 0.95),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: isDark ? Colors.white : const Color(0xFF141316)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Settings',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: isDark ? Colors.white : const Color(0xFF141316),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          _buildSectionHeader('SECURITY & APPEARANCE'),
          _buildSettingsCard([
            _buildToggleItem(
              icon: Icons.fingerprint,
              title: 'Biometric Lock',
              value: _biometricLock,
              onChanged: (val) => setState(() => _biometricLock = val),
              showBorder: true,
            ),
            _buildNavigationItem(
              icon: Icons.palette_outlined,
              title: 'Theme',
              subtitle: _getThemeName(themeProvider.themeMode),
              onTap: _showThemeDialog,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionHeader('CLOUD BACKUP'),
          _buildCloudBackupCard(),
          const SizedBox(height: 32),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: safeGoogleFont(
          'IBM Plex Sans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCAC4D0).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: const Color(0xFFCAC4D0).withValues(alpha: 0.3),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          _buildIconContainer(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: safeGoogleFont(
                'IBM Plex Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF141316),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6751a4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildIconContainer(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: safeGoogleFont(
                  'IBM Plex Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF141316),
                ),
              ),
            ),
            Text(
              subtitle,
              style: safeGoogleFont(
                'IBM Plex Sans',
                fontSize: 16,
                color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.6),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCAC4D0)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : const Color(0xFFF2F1F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: isDark ? Colors.white : const Color(0xFF141316), size: 24),
    );
  }

  Widget _buildCloudBackupCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCAC4D0).withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF6751a4).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_sync,
                  color: Color(0xFF6751a4),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-backup',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF141316),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Back up your diary entries to Google Drive automatically.',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoBackup,
                onChanged: (val) => setState(() => _autoBackup = val),
                activeThumbColor: const Color(0xFF6751a4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: const Color(0xFFCAC4D0).withValues(alpha: 0.3),
            height: 1,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.history, size: 18, color: isDark ? Colors.white : const Color(0xFF141316)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Last backup: ',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.7),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'Oct 24, 2023 • 10:42 AM',
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF141316),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              foregroundColor: isDark ? Colors.white : const Color(0xFF1F1F1F),
              elevation: 0,
              side: const BorderSide(color: Color(0xFFCAC4D0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.backup, size: 20, color: Color(0xFF4285F4)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Backup to Google Drive',
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(Icons.lock, size: 24, color: isDark ? Colors.white : const Color(0xFF141316)),
        const SizedBox(height: 8),
        Text(
          'Your data is encrypted locally.',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 2.4.0',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 10,
            color: (isDark ? Colors.white : const Color(0xFF141316)).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
