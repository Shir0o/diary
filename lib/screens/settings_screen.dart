import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/font_helper.dart';
import '../services/auth_service.dart';
import '../services/drive_service.dart';
import '../services/security_service.dart';
import '../services/theme_service.dart';
import '../config/app_theme.dart';
import '../data/diary_entry_store.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  final AuthService authService;
  final SecurityService securityService;
  final ThemeService themeService;
  final DiaryEntryStore entryStore;
  final VoidCallback? onSyncCompleted;

  const SettingsScreen({
    super.key,
    this.onMenuPressed,
    required this.authService,
    required this.securityService,
    required this.themeService,
    required this.entryStore,
    this.onSyncCompleted,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  static const _lastSyncAtKey = 'last_sync_at';

  bool _biometricLock = false;
  bool _autoBackup = true;
  bool _isSyncing = false;
  DateTime? _lastSyncAt;
  late AnimationController _syncAnimationController;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadSettings();
  }

  @override
  void dispose() {
    _syncAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final enabled = await widget.securityService.isBiometricLockEnabled;
    final prefs = await SharedPreferences.getInstance();
    final lastSyncIso = prefs.getString(_lastSyncAtKey);
    final autoSyncEnabled = prefs.getBool('auto_sync') ?? true;
    if (mounted) {
      setState(() {
        _biometricLock = enabled;
        _autoBackup = autoSyncEnabled;
        _lastSyncAt = lastSyncIso != null
            ? DateTime.tryParse(lastSyncIso)
            : null;
      });
    }
  }

  Future<void> _saveLastSyncAt(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncAtKey, value.toUtc().toIso8601String());
  }

  Future<void> _toggleBiometricLock(bool enabled) async {
    if (enabled) {
      // If enabling, verify we can authenticate first
      final canAuth = await widget.securityService.canAuthenticate();
      if (!canAuth) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication is not available'),
            ),
          );
        }
        return;
      }

      final authenticated = await widget.securityService.authenticate();
      if (!authenticated) return;
    }

    await widget.securityService.setBiometricLockEnabled(enabled);
    if (mounted) {
      setState(() {
        _biometricLock = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: colorScheme.onSurface),
            onPressed:
                widget.onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Settings',
          style: safeGoogleFont(
            'IBM Plex Sans',
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<GoogleSignInAccount?>(
        stream: widget.authService.onCurrentUserChanged,
        initialData: widget.authService.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: AppTheme.spacingSmall),
              _buildSectionHeader('ACCOUNT'),
              _buildSettingsCard([
                if (user == null)
                  _buildActionItem(
                    icon: Icons.login,
                    title: 'Sign in with Google',
                    onTap: () async {
                      await widget.authService.signIn();
                    },
                  )
                else
                  _buildAccountItem(user),
              ]),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildSectionHeader('SECURITY & APPEARANCE'),
              _buildSettingsCard([
                _buildToggleItem(
                  icon: Icons.fingerprint,
                  title: 'Biometric Lock',
                  value: _biometricLock,
                  onChanged: _toggleBiometricLock,
                  showBorder: true,
                ),
                _buildDropdownItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  value: ThemeModeOption.fromMode(
                    widget.themeService.themeMode,
                  ),
                  items: ThemeModeOption.values,
                  onChanged: (ThemeModeOption? newValue) {
                    if (newValue != null) {
                      widget.themeService.setThemeMode(newValue.mode);
                    }
                  },
                ),
              ]),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildSectionHeader('CLOUD SYNC'),
              _buildCloudBackupCard(user != null),
              const SizedBox(height: AppTheme.spacingExtraLarge),
              _buildFooter(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required ThemeModeOption value,
    required List<ThemeModeOption> items,
    required ValueChanged<ThemeModeOption?> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: colorScheme.onSurface),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Text(
              title,
              style: safeGoogleFont(
                'IBM Plex Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<ThemeModeOption>(
              value: value,
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
              dropdownColor: colorScheme.surface,
              items: items.map((option) {
                return DropdownMenuItem<ThemeModeOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: safeGoogleFont(
          'IBM Plex Sans',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountItem(GoogleSignInAccount user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Google User',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        _buildActionItem(
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () async {
            await widget.authService.signOut();
          },
          textColor: Colors.red[700],
          iconColor: Colors.red[700],
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.onSurface;
    final effectiveTextColor = textColor ?? colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: safeGoogleFont(
                  'IBM Plex Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showBorder = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
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
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colorScheme.onSurface, size: 24),
    );
  }

  Widget _buildCloudBackupCard(bool isSignedIn) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isDark ? 0.2 : 0.05),
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
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_sync,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-sync',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSignedIn
                          ? 'Keep your diary entries in sync with Google Drive.'
                          : 'Sign in to sync your entries with Google Drive.',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoBackup && isSignedIn,
                onChanged: isSignedIn
                    ? (val) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('auto_sync', val);
                        if (mounted) {
                          setState(() => _autoBackup = val);
                        }
                      }
                    : null,
                activeThumbColor: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: colorScheme.outline.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.history, size: 18, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Last sync: ',
                      style: safeGoogleFont(
                        'IBM Plex Sans',
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        isSignedIn ? _formatLastSync() : 'Not available',
                        style: safeGoogleFont(
                          'IBM Plex Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSignedIn
                  ? () {
                      if (!_isSyncing) _runSync();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSyncing
                    ? colorScheme.primary.withValues(alpha: 0.8)
                    : colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                disabledBackgroundColor: colorScheme.onSurface.withValues(
                  alpha: 0.12,
                ),
                disabledForegroundColor: colorScheme.onSurface.withValues(
                  alpha: 0.38,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotationTransition(
                    turns: _syncAnimationController,
                    child: const Icon(Icons.sync, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSyncing ? 'Syncing…' : 'Sync now',
                    style: safeGoogleFont(
                      'IBM Plex Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildFooter() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(Icons.lock, size: 24, color: colorScheme.onSurface),
        const SizedBox(height: 8),
        Text(
          'Your data is encrypted locally.',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 0.1.0',
          style: safeGoogleFont(
            'IBM Plex Sans',
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Future<void> _runSync() async {
    setState(() => _isSyncing = true);
    _syncAnimationController.repeat();
    try {
      final result = await widget.authService.driveService.sync(
        widget.entryStore,
      );
      if (!mounted) return;
      final syncedAt = result.remoteModified ?? DateTime.now();
      await _saveLastSyncAt(syncedAt);
      if (!mounted) return;
      setState(() {
        _lastSyncAt = syncedAt;
      });
      final message = switch (result.outcome) {
        SyncOutcome.uploaded => 'Synced — local changes uploaded.',
        SyncOutcome.downloaded => 'Synced — remote changes downloaded.',
        SyncOutcome.alreadyInSync => 'Already up to date.',
      };

      if (result.outcome == SyncOutcome.downloaded &&
          widget.onSyncCompleted != null) {
        widget.onSyncCompleted!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _syncAnimationController.stop();
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  String _formatLastSync() {
    final syncAt = _lastSyncAt;
    if (syncAt == null) return 'Never';
    return DateFormat('MMM d, yyyy • h:mm a').format(syncAt);
  }
}
