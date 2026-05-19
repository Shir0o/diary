import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/diary_entry_store.dart';
import 'data/sqlite_diary_entry_store.dart';
import 'screens/timeline_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/media_screen.dart';
import 'screens/info_screen.dart';
import 'screens/entry_search_delegate.dart';
import 'screens/archive_screen.dart';
import 'screens/biometric_lock_screen.dart';
import 'widgets/side_drawer.dart';
import 'models/diary_entry.dart';
import 'services/auth_service.dart';
import 'services/security_service.dart';
import 'services/theme_service.dart';
import 'config/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);

  final authService = AuthService();
  await authService.silentSignIn();

  final securityService = SecurityService();
  final themeService = ThemeService();

  runApp(
    DiaryApp(
      authService: authService,
      securityService: securityService,
      themeService: themeService,
    ),
  );
}

class DiaryApp extends StatelessWidget {
  final DiaryEntryStore? entryStore;
  final AuthService authService;
  final SecurityService securityService;
  final ThemeService themeService;

  const DiaryApp({
    super.key,
    this.entryStore,
    required this.authService,
    required this.securityService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Diary',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: MainScreen(
            entryStore: entryStore ?? SqliteDiaryEntryStore(),
            authService: authService,
            securityService: securityService,
            themeService: themeService,
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final DiaryEntryStore entryStore;
  final AuthService authService;
  final SecurityService securityService;
  final ThemeService themeService;

  const MainScreen({
    super.key,
    required this.entryStore,
    required this.authService,
    required this.securityService,
    required this.themeService,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;

  static const List<_MainDestination> _destinations = [
    _MainDestination(drawerIndex: 0, screen: _MainScreen.timeline),
    _MainDestination(drawerIndex: 1, screen: _MainScreen.calendar),
    _MainDestination(drawerIndex: 2, screen: _MainScreen.archive),
    _MainDestination(drawerIndex: 3, screen: _MainScreen.media),
    _MainDestination(drawerIndex: 4, screen: _MainScreen.analytics),
    _MainDestination(drawerIndex: 5, screen: _MainScreen.settings),
    _MainDestination(drawerIndex: 6, screen: _MainScreen.help),
    _MainDestination(drawerIndex: 7, screen: _MainScreen.about),
  ];

  _MainScreen _currentScreen = _MainScreen.timeline;
  List<DiaryEntry> _entries = [];
  bool _isLoadingEntries = true;
  Timer? _autoSyncTimer;
  bool _autoDeleteTrash = true;
  int _trashRetentionDays = 30;

  void _triggerAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer(const Duration(seconds: 5), () async {
      final prefs = await SharedPreferences.getInstance();
      final autoSync = prefs.getBool('auto_sync') ?? true;
      final isSignedIn = widget.authService.currentUser != null;
      if (autoSync && isSignedIn) {
        try {
          await widget.authService.driveService.sync(widget.entryStore);
          await _loadEntries();
        } catch (e) {
          debugPrint('Auto-sync failed: $e');
        }
      }
    });
  }

  Future<void> _triggerImmediateSync() async {
    final prefs = await SharedPreferences.getInstance();
    final autoSync = prefs.getBool('auto_sync') ?? true;
    final isSignedIn = widget.authService.currentUser != null;
    if (autoSync && isSignedIn) {
      try {
        await widget.authService.driveService.sync(widget.entryStore);
        await _loadEntries();
      } catch (e) {
        debugPrint('Immediate sync failed: $e');
      }
    }
  }

  static final List<DiaryEntry> _defaultEntries = [
    DiaryEntry(
      id: '1',
      date: DateTime(2026, 4, 24, 10, 0),
      title: 'Starting a new project',
      content: 'Today I started the Diary app project.',
      mood: '🚀',
      location: 'Home Office',
    ),
    DiaryEntry(
      id: '2',
      date: DateTime(2026, 4, 24, 14, 0),
      title: 'Coffee Break',
      content: 'Had a wonderful cup of coffee.',
      mood: '☕',
      location: 'Local Cafe',
    ),
    DiaryEntry(
      id: '3',
      date: DateTime(2026, 4, 23, 11, 0),
      title: 'Planning phase',
      content: 'Spent the day planning.',
      mood: '📝',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
    _loadEntries();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSyncTimer?.cancel();
    widget.entryStore.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthentication();
      _triggerImmediateSync();
    } else if (state == AppLifecycleState.paused) {
      if (_isAuthenticating) return;
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  Future<void> _checkAuthentication() async {
    final isLocked = await widget.securityService.isBiometricLockEnabled;
    if (!isLocked) {
      setState(() {
        _isAuthenticated = true;
      });
      return;
    }

    if (_isAuthenticated || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    final authenticated = await widget.securityService.authenticate();

    if (mounted) {
      setState(() {
        _isAuthenticated = authenticated;
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final autoDelete = prefs.getBool('auto_delete_trash') ?? true;
    final retentionDays = prefs.getInt('trash_retention_days') ?? 30;

    if (mounted) {
      setState(() {
        _autoDeleteTrash = autoDelete;
        _trashRetentionDays = retentionDays;
      });
    }

    if (autoDelete) {
      final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
      await widget.entryStore.deleteEntriesDeletedBefore(cutoff);
    }

    await widget.entryStore.seedEntriesIfEmpty(_defaultEntries);
    final entries = await widget.entryStore.loadEntries();

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoadingEntries = false;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _createEntry() async {
    final existingTags = _entries.expand((e) => e.tags).toSet().toList();
    final entry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (context) => NewEntryScreen(existingTags: existingTags),
      ),
    );
    if (entry == null) return;

    await widget.entryStore.upsertEntry(entry);

    setState(() {
      _entries.insert(0, entry);
      _sortEntries();
    });
    _triggerAutoSync();
  }

  Future<void> _editEntry(DiaryEntry entry) async {
    final existingTags = _entries.expand((e) => e.tags).toSet().toList();
    final updatedEntry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(
        builder: (context) =>
            NewEntryScreen(entry: entry, existingTags: existingTags),
      ),
    );
    if (updatedEntry == null) return;

    await widget.entryStore.upsertEntry(updatedEntry);

    setState(() {
      final index = _entries.indexWhere((item) => item.id == updatedEntry.id);
      if (index == -1) return;
      _entries[index] = updatedEntry;
      _sortEntries();
    });
    _triggerAutoSync();
  }

  void _showUndoSnackBar({
    required String message,
    required Future<void> Function() onUndo,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            try {
              await onUndo();
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to undo action: $e'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteEntry(String id) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    await widget.entryStore.trashEntry(id, true);
    if (!mounted) return;
    setState(() {
      _entries[index] = _entries[index].copyWith(isDeleted: true);
    });
    _triggerAutoSync();

    _showUndoSnackBar(
      message: 'Entry moved to Trash',
      onUndo: () async {
        await widget.entryStore.trashEntry(id, false);
        if (!mounted) return;
        setState(() {
          final idx = _entries.indexWhere((item) => item.id == id);
          if (idx != -1) {
            _entries[idx] = _entries[idx].copyWith(isDeleted: false);
          }
        });
        _triggerAutoSync();
      },
    );
  }

  Future<void> _archiveEntry(String id, bool archived) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    await widget.entryStore.archiveEntry(id, archived);
    if (!mounted) return;
    setState(() {
      _entries[index] = _entries[index].copyWith(isArchived: archived);
    });
    _triggerAutoSync();

    _showUndoSnackBar(
      message: archived ? 'Entry archived' : 'Entry unarchived',
      onUndo: () async {
        await widget.entryStore.archiveEntry(id, !archived);
        if (!mounted) return;
        setState(() {
          final idx = _entries.indexWhere((item) => item.id == id);
          if (idx != -1) {
            _entries[idx] = _entries[idx].copyWith(isArchived: !archived);
          }
        });
        _triggerAutoSync();
      },
    );
  }

  Future<void> _restoreEntry(String id) async {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final entry = _entries[index];
    final wasArchived = entry.isArchived;
    final wasDeleted = entry.isDeleted;

    await widget.entryStore.archiveEntry(id, false);
    await widget.entryStore.trashEntry(id, false);
    if (!mounted) return;
    setState(() {
      _entries[index] = _entries[index].copyWith(
        isArchived: false,
        isDeleted: false,
      );
    });
    _triggerAutoSync();

    _showUndoSnackBar(
      message: 'Entry restored',
      onUndo: () async {
        if (wasArchived) {
          await widget.entryStore.archiveEntry(id, true);
        }
        if (wasDeleted) {
          await widget.entryStore.trashEntry(id, true);
        }
        if (!mounted) return;
        setState(() {
          final idx = _entries.indexWhere((item) => item.id == id);
          if (idx != -1) {
            _entries[idx] = _entries[idx].copyWith(
              isArchived: wasArchived,
              isDeleted: wasDeleted,
            );
          }
        });
        _triggerAutoSync();
      },
    );
  }

  Future<void> _permanentlyDeleteEntry(String id) async {
    await widget.entryStore.permanentlyDeleteEntry(id);
    if (!mounted) return;
    setState(() {
      _entries.removeWhere((item) => item.id == id);
    });
    _triggerAutoSync();
  }

  Future<void> _emptyTrash() async {
    final deletedIds = _entries
        .where((e) => e.isDeleted)
        .map((e) => e.id)
        .toList();
    if (deletedIds.isEmpty) return;

    for (final id in deletedIds) {
      await widget.entryStore.permanentlyDeleteEntry(id);
    }

    if (!mounted) return;
    setState(() {
      _entries.removeWhere((e) => deletedIds.contains(e.id));
    });
    _triggerAutoSync();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trash emptied successfully'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sortEntries() {
    _entries.sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> _searchEntries() async {
    final selectedEntry = await showSearch<DiaryEntry?>(
      context: context,
      delegate: EntrySearchDelegate(_entries),
    );
    if (selectedEntry == null) return;
    await _editEntry(selectedEntry);
  }

  void _showCalendar() {
    setState(() {
      _currentScreen = _MainScreen.calendar;
    });
  }

  void _onItemSelected(int index) {
    final destination = _destinationForDrawerIndex(index);
    if (destination == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _currentScreen = destination.screen;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  _MainDestination? _destinationForDrawerIndex(int drawerIndex) {
    final destinationIndex = _destinations.indexWhere(
      (destination) => destination.drawerIndex == drawerIndex,
    );
    return destinationIndex == -1 ? null : _destinations[destinationIndex];
  }

  int get _selectedDrawerIndex {
    return _destinations
        .firstWhere((destination) => destination.screen == _currentScreen)
        .drawerIndex;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return BiometricLockScreen(
        onUnlock: _checkAuthentication,
        isAuthenticating: _isAuthenticating,
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(
        onItemSelected: _onItemSelected,
        selectedIndex: _selectedDrawerIndex,
        authService: widget.authService,
      ),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isLoadingEntries) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return switch (_currentScreen) {
      _MainScreen.timeline => TimelineScreen(
        entries: _entries.where((e) => !e.isArchived && !e.isDeleted).toList(),
        onMenuPressed: _openDrawer,
        onAddEntry: _createEntry,
        onSearchEntries: _searchEntries,
        onCalendarPressed: _showCalendar,
        onEditEntry: _editEntry,
        onDeleteEntry: _deleteEntry,
        onArchiveEntry: (id) => _archiveEntry(id, true),
        onRefresh: () async {
          final isSignedIn = widget.authService.currentUser != null;
          if (isSignedIn) {
            try {
              await widget.authService.driveService.sync(widget.entryStore);
              await _loadEntries();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sync failed: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      ),
      _MainScreen.calendar => CalendarScreen(
        entries: _entries.where((e) => !e.isDeleted).toList(),
        onMenuPressed: _openDrawer,
        onSearchEntries: _searchEntries,
        onEditEntry: _editEntry,
      ),
      _MainScreen.archive => ArchiveScreen(
        archivedEntries: _entries
            .where((e) => e.isArchived && !e.isDeleted)
            .toList(),
        deletedEntries: _entries.where((e) => e.isDeleted).toList(),
        onMenuPressed: _openDrawer,
        onRestoreEntry: _restoreEntry,
        onDeleteEntry: _deleteEntry,
        onPermanentlyDeleteEntry: _permanentlyDeleteEntry,
        onEmptyTrash: _emptyTrash,
        autoDeleteEnabled: _autoDeleteTrash,
        retentionDays: _trashRetentionDays,
      ),
      _MainScreen.media => MediaScreen(
        entries: _entries.where((e) => !e.isDeleted).toList(),
        onMenuPressed: _openDrawer,
      ),
      _MainScreen.analytics => AnalyticsScreen(
        entries: _entries.where((e) => !e.isDeleted).toList(),
        onMenuPressed: _openDrawer,
      ),
      _MainScreen.settings => SettingsScreen(
        onMenuPressed: _openDrawer,
        authService: widget.authService,
        securityService: widget.securityService,
        themeService: widget.themeService,
        entryStore: widget.entryStore,
        onSyncCompleted: _loadEntries,
      ),
      _MainScreen.help => InfoScreen.help(onMenuPressed: _openDrawer),
      _MainScreen.about => InfoScreen.about(onMenuPressed: _openDrawer),
    };
  }
}

class _MainDestination {
  final int drawerIndex;
  final _MainScreen screen;

  const _MainDestination({required this.drawerIndex, required this.screen});
}

enum _MainScreen {
  timeline,
  calendar,
  archive,
  media,
  analytics,
  settings,
  help,
  about,
}
