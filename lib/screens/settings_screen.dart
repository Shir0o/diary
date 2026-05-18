import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../helpers/font_helper.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const SettingsScreen({super.key, this.onMenuPressed});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricLock = false;
  bool _autoBackup = true;
  String _themeLabel = 'System Default';
  DateTime? _lastBackupAt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF).withValues(alpha: 0.95),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF141316)),
            onPressed:
                widget.onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Settings',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: const Color(0xFF141316),
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
              subtitle: _themeLabel,
              onTap: _pickTheme,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: safeGoogleFont(
          'IBM Plex Sans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF141316).withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: const Color(0xFF141316),
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
                  color: const Color(0xFF141316),
                ),
              ),
            ),
            Text(
              subtitle,
              style: safeGoogleFont(
                'IBM Plex Sans',
                fontSize: 16,
                color: const Color(0xFF141316).withValues(alpha: 0.6),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCAC4D0)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: const Color(0xFF141316), size: 24),
    );
  }

  Widget _buildCloudBackupCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        color: const Color(0xFF141316),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Back up your diary entries to Google Drive automatically.',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: const Color(0xFF141316).withValues(alpha: 0.6),
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
              const Icon(Icons.history, size: 18, color: Color(0xFF141316)),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Last backup: ',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: const Color(0xFF141316).withValues(alpha: 0.7),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _formatLastBackup(),
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF141316),
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
            onPressed: _runManualBackup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1F1F1F),
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
                // Simplified Google Logo with Icons
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
    return Column(
      children: [
        const Icon(Icons.lock, size: 24, color: Color(0xFF141316)),
        const SizedBox(height: 8),
        Text(
          'Your data is encrypted locally.',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF141316).withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 0.1.0',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 10,
            color: const Color(0xFF141316).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _pickTheme() async {
    final selectedTheme = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Theme'),
          children: [
            for (final theme in const ['System Default', 'Light', 'Dark'])
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(theme),
                child: Text(theme),
              ),
          ],
        );
      },
    );
    if (selectedTheme == null) return;
    setState(() {
      _themeLabel = selectedTheme;
    });
  }

  void _runManualBackup() {
    final hasGoogleConfig =
        AppConfig.googleAndroidClientId.isNotEmpty ||
        AppConfig.googleIosClientId.isNotEmpty ||
        AppConfig.googleWebClientId.isNotEmpty;
    setState(() {
      _lastBackupAt = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasGoogleConfig
              ? 'Backup queued for Google Drive.'
              : 'Google Drive client ID is not configured.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatLastBackup() {
    final backupAt = _lastBackupAt;
    if (backupAt == null) return 'Never';
    return DateFormat('MMM d, yyyy • h:mm a').format(backupAt);
  }
}
