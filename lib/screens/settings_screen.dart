import 'dart:async';
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
import '../widgets/skeleton_loader.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBackPressed;
  final AuthService authService;
  final SecurityService securityService;
  final ThemeService themeService;
  final DiaryEntryStore entryStore;
  final VoidCallback? onSyncCompleted;
  final ValueChanged<String>? onNavigateToScreen;
  final bool isLoading;

  const SettingsScreen({
    super.key,
    required this.onBackPressed,
    required this.authService,
    required this.securityService,
    required this.themeService,
    required this.entryStore,
    this.onSyncCompleted,
    this.onNavigateToScreen,
    this.isLoading = false,
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
  bool _autoDeleteTrash = true;
  int _trashRetentionDays = 30;
  late final TextEditingController _nameController;

  String _safeUserName() {
    try {
      return widget.themeService.userName;
    } catch (_) {
      return 'User';
    }
  }

  String _safePalette() {
    try {
      return widget.themeService.themePalette;
    } catch (_) {
      return 'lilac';
    }
  }

  ThemeMode _safeThemeMode() {
    try {
      return widget.themeService.themeMode;
    } catch (_) {
      return ThemeMode.system;
    }
  }

  StreamSubscription<GoogleSignInAccount?>? _userSub;

  @override
  void initState() {
    super.initState();
    _syncAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _nameController = TextEditingController(text: _safeUserName());
    _loadSettings();
    _userSub = widget.authService.onCurrentUserChanged.listen((user) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _syncAnimationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final enabled = await widget.securityService.isBiometricLockEnabled;
    final prefs = await SharedPreferences.getInstance();
    final lastSyncIso = prefs.getString(_lastSyncAtKey);
    final autoSyncEnabled = prefs.getBool('auto_sync') ?? true;
    final autoDelete = prefs.getBool('auto_delete_trash') ?? true;
    final retentionDays = prefs.getInt('trash_retention_days') ?? 30;
    if (mounted) {
      setState(() {
        _biometricLock = enabled;
        _autoBackup = autoSyncEnabled;
        _lastSyncAt = lastSyncIso != null
            ? DateTime.tryParse(lastSyncIso)
            : null;
        _autoDeleteTrash = autoDelete;
        _trashRetentionDays = retentionDays;
      });
    }
  }

  Future<void> _saveLastSyncAt(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncAtKey, value.toUtc().toIso8601String());
  }

  Future<void> _toggleBiometricLock(bool enabled) async {
    if (enabled) {
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

  void _showNameEditDialog() {
    _nameController.text = widget.themeService.userName;
    showDialog(
      context: context,
      builder: (context) {
        final brightness = Theme.of(context).brightness;
        return AlertDialog(
          backgroundColor: AppTheme.getCardBackground(
            brightness,
            widget.themeService.themePalette,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Name',
            style: safeGoogleFont(
              'Quicksand',
              fontWeight: FontWeight.bold,
              color: AppTheme.getHeadingColor(brightness),
            ),
          ),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            style: safeGoogleFont(
              'Quicksand',
              color: AppTheme.getHeadingColor(brightness),
            ),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(color: AppTheme.getFaintColor(brightness)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: safeGoogleFont('Quicksand', fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  widget.themeService.setUserName(name);
                  setState(() {});
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: safeGoogleFont('Quicksand', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final palette = _safePalette();

    final bgGradient = AppTheme.getScreenBackground(brightness, palette);
    final headingColor = AppTheme.getHeadingColor(brightness);
    final mutedColor = AppTheme.getMutedColor(brightness);

    return Scaffold(
      backgroundColor: bgGradient.colors.first,
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: widget.onBackPressed,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Settings',
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings scroll list
              Expanded(
                child: widget.isLoading
                    ? const SettingsScreenSkeleton()
                    : Builder(
                        builder: (context) {
                          final user = widget.authService.currentUser;

                          return ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            children: [
                              _buildSectionHeader('ACCOUNT'),
                              _buildSettingsCard(brightness, palette, [
                                if (user == null)
                                  _buildActionItem(
                                    brightness,
                                    palette,
                                    icon: Icons.login,
                                    title: 'Sign in with Google',
                                    onTap: () async {
                                      await widget.authService.signIn();
                                    },
                                  )
                                else
                                  _buildAccountItem(brightness, palette, user),
                                const Divider(height: 1),
                                Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    onTap: _showNameEditDialog,
                                    leading: const Text(
                                      '👋',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    title: Text(
                                      'Your name',
                                      style: safeGoogleFont(
                                        'Quicksand',
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _safeUserName(),
                                          style: safeGoogleFont(
                                            'Quicksand',
                                            color: mutedColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: AppTheme.getFaintColor(
                                            brightness,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 10),

                              _buildSectionHeader('SECURITY & APPEARANCE'),
                              _buildSettingsCard(brightness, palette, [
                                _buildToggleItem(
                                  brightness,
                                  palette,
                                  icon: Icons.fingerprint,
                                  title: 'Biometric Lock',
                                  value: _biometricLock,
                                  onChanged: _toggleBiometricLock,
                                ),
                                const Divider(height: 1),
                                _buildDropdownItem(
                                  brightness,
                                  palette,
                                  icon: Icons.palette_outlined,
                                  title: 'Appearance mode',
                                  value: ThemeModeOption.fromMode(
                                    _safeThemeMode(),
                                  ),
                                  items: ThemeModeOption.values,
                                  onChanged: (ThemeModeOption? newValue) {
                                    if (newValue != null) {
                                      widget.themeService.setThemeMode(
                                        newValue.mode,
                                      );
                                    }
                                  },
                                ),
                              ]),
                              const SizedBox(height: 10),

                              _buildSectionHeader('TRASH & ARCHIVE'),
                              _buildSettingsCard(brightness, palette, [
                                _buildToggleItem(
                                  brightness,
                                  palette,
                                  icon: Icons.auto_delete_outlined,
                                  title: 'Auto-delete Trash',
                                  value: _autoDeleteTrash,
                                  onChanged: (val) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                      'auto_delete_trash',
                                      val,
                                    );
                                    setState(() {
                                      _autoDeleteTrash = val;
                                    });
                                    widget.onSyncCompleted?.call();
                                  },
                                ),
                                if (_autoDeleteTrash) ...[
                                  const Divider(height: 1),
                                  _buildRetentionPeriodItem(
                                    brightness,
                                    palette,
                                  ),
                                ],
                                const Divider(height: 1),
                                _buildActionItem(
                                  brightness,
                                  palette,
                                  icon: Icons.photo_library_outlined,
                                  title: 'Media Gallery',
                                  onTap: () =>
                                      widget.onNavigateToScreen?.call('media'),
                                ),
                                const Divider(height: 1),
                                _buildActionItem(
                                  brightness,
                                  palette,
                                  icon: Icons.archive_outlined,
                                  title: 'View Archive',
                                  onTap: () => widget.onNavigateToScreen?.call(
                                    'archive',
                                  ),
                                ),
                                const Divider(height: 1),
                                _buildActionItem(
                                  brightness,
                                  palette,
                                  icon: Icons.delete_outline,
                                  title: 'View Trash',
                                  onTap: () =>
                                      widget.onNavigateToScreen?.call('trash'),
                                ),
                              ]),
                              const SizedBox(height: 10),

                              _buildSectionHeader('CLOUD SYNC'),
                              _buildCloudBackupCard(
                                brightness,
                                palette,
                                user != null,
                              ),
                              const SizedBox(height: 32),
                              _buildFooter(brightness),
                              const SizedBox(height: 50),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRetentionPeriodItem(Brightness brightness, String palette) {
    final headingColor = AppTheme.getHeadingColor(brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: AppTheme.getMutedColor(brightness),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Retention Period',
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _trashRetentionDays,
              onChanged: (int? newValue) async {
                if (newValue != null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('trash_retention_days', newValue);
                  setState(() {
                    _trashRetentionDays = newValue;
                  });
                  widget.onSyncCompleted?.call();
                }
              },
              icon: Icon(Icons.arrow_drop_down, color: headingColor),
              dropdownColor: AppTheme.getCardBackground(brightness, palette),
              items: const [
                DropdownMenuItem<int>(value: 7, child: Text('7 days')),
                DropdownMenuItem<int>(value: 30, child: Text('30 days')),
                DropdownMenuItem<int>(value: 90, child: Text('90 days')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(
    Brightness brightness,
    String palette, {
    required IconData icon,
    required String title,
    required ThemeModeOption value,
    required List<ThemeModeOption> items,
    required ValueChanged<ThemeModeOption?> onChanged,
  }) {
    final headingColor = AppTheme.getHeadingColor(brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.getMutedColor(brightness), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<ThemeModeOption>(
              value: value,
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down, color: headingColor),
              dropdownColor: AppTheme.getCardBackground(brightness, palette),
              items: items.map((option) {
                return DropdownMenuItem<ThemeModeOption>(
                  value: option,
                  child: Text(
                    option.label,
                    style: safeGoogleFont(
                      'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: headingColor,
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
    final brightness = Theme.of(context).brightness;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        title,
        style: safeGoogleFont(
          'Space Mono',
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
          color: AppTheme.getFaintColor(brightness),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    Brightness brightness,
    String palette,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(brightness, palette),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountItem(
    Brightness brightness,
    String palette,
    GoogleSignInAccount user,
  ) {
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
                        'Quicksand',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getHeadingColor(brightness),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 13,
                        color: AppTheme.getMutedColor(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildActionItem(
          brightness,
          palette,
          icon: Icons.logout,
          title: 'Sign Out',
          onTap: () async {
            await widget.authService.signOut();
          },
          textColor: Colors.red[600],
          iconColor: Colors.red[600],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    Brightness brightness,
    String palette, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.getMutedColor(brightness);
    final effectiveTextColor =
        textColor ?? AppTheme.getHeadingColor(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: effectiveIconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: safeGoogleFont(
                  'Quicksand',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: effectiveTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.getFaintColor(brightness),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    Brightness brightness,
    String palette, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final headingColor = AppTheme.getHeadingColor(brightness);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.getMutedColor(brightness), size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: safeGoogleFont(
                'Quicksand',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.getPrimaryColor(palette),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudBackupCard(
    Brightness brightness,
    String palette,
    bool isSignedIn,
  ) {
    final headingColor = AppTheme.getHeadingColor(brightness);
    final mutedColor = AppTheme.getMutedColor(brightness);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(brightness, palette),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getHairlineColor(brightness)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.getSoftBg(palette),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.cloud_sync,
                    color: AppTheme.getPrimaryColor(palette),
                    size: 24,
                  ),
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
                        'Quicksand',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSignedIn
                          ? 'Keep your diary entries in sync with Google Drive.'
                          : 'Sign in to sync your entries with Google Drive.',
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 13,
                        color: mutedColor,
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
                activeColor: AppTheme.getPrimaryColor(palette),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppTheme.getHairlineColor(brightness), height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Last sync: ',
                      style: safeGoogleFont(
                        'Quicksand',
                        fontSize: 13.5,
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        isSignedIn ? _formatLastSync() : 'Not available',
                        style: safeGoogleFont(
                          'Quicksand',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSignedIn
                  ? () {
                      if (!_isSyncing) _runSync();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getPrimaryColor(palette),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotationTransition(
                    turns: _syncAnimationController,
                    child: const Icon(
                      Icons.sync,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isSyncing ? 'Syncing…' : 'Sync now',
                    style: safeGoogleFont(
                      'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildFooter(Brightness brightness) {
    return Column(
      children: [
        Icon(
          Icons.lock_outline,
          size: 22,
          color: AppTheme.getFaintColor(brightness),
        ),
        const SizedBox(height: 8),
        Text(
          'Your data is encrypted locally.',
          style: safeGoogleFont(
            'Quicksand',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.getFaintColor(brightness),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: safeGoogleFont(
            'Space Mono',
            fontSize: 10,
            color: AppTheme.getFaintColor(brightness),
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
