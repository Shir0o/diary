import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'widgets/side_drawer.dart';
import 'models/diary_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  runApp(const DiaryApp());
}

class DiaryApp extends StatelessWidget {
  final DiaryEntryStore? entryStore;

  const DiaryApp({super.key, this.entryStore});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6751a4)),
        useMaterial3: true,
      ),
      home: MainScreen(entryStore: entryStore ?? SqliteDiaryEntryStore()),
    );
  }
}

class MainScreen extends StatefulWidget {
  final DiaryEntryStore entryStore;

  const MainScreen({super.key, required this.entryStore});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<_MainDestination> _destinations = [
    _MainDestination(drawerIndex: 0, screen: _MainScreen.timeline),
    _MainDestination(drawerIndex: 1, screen: _MainScreen.calendar),
    _MainDestination(drawerIndex: 2, screen: _MainScreen.media),
    _MainDestination(drawerIndex: 3, screen: _MainScreen.analytics),
    _MainDestination(drawerIndex: 4, screen: _MainScreen.settings),
    _MainDestination(drawerIndex: 5, screen: _MainScreen.help),
    _MainDestination(drawerIndex: 6, screen: _MainScreen.about),
  ];

  _MainScreen _currentScreen = _MainScreen.timeline;
  List<DiaryEntry> _entries = [];
  bool _isLoadingEntries = true;

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
    _loadEntries();
  }

  @override
  void dispose() {
    widget.entryStore.close();
    super.dispose();
  }

  Future<void> _loadEntries() async {
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
    final entry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(builder: (context) => const NewEntryScreen()),
    );
    if (entry == null) return;

    await widget.entryStore.upsertEntry(entry);

    setState(() {
      _entries.insert(0, entry);
      _sortEntries();
    });
  }

  Future<void> _editEntry(DiaryEntry entry) async {
    final updatedEntry = await Navigator.of(context).push<DiaryEntry>(
      MaterialPageRoute(builder: (context) => NewEntryScreen(entry: entry)),
    );
    if (updatedEntry == null) return;

    await widget.entryStore.upsertEntry(updatedEntry);

    setState(() {
      final index = _entries.indexWhere((item) => item.id == updatedEntry.id);
      if (index == -1) return;
      _entries[index] = updatedEntry;
      _sortEntries();
    });
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
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(
        onItemSelected: _onItemSelected,
        selectedIndex: _selectedDrawerIndex,
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
        entries: _entries,
        onMenuPressed: _openDrawer,
        onAddEntry: _createEntry,
        onSearchEntries: _searchEntries,
        onCalendarPressed: _showCalendar,
        onEditEntry: _editEntry,
      ),
      _MainScreen.calendar => CalendarScreen(
        entries: _entries,
        onMenuPressed: _openDrawer,
        onSearchEntries: _searchEntries,
        onEditEntry: _editEntry,
      ),
      _MainScreen.media => MediaScreen(
        entries: _entries,
        onMenuPressed: _openDrawer,
      ),
      _MainScreen.analytics => AnalyticsScreen(
        entries: _entries,
        onMenuPressed: _openDrawer,
      ),
      _MainScreen.settings => SettingsScreen(onMenuPressed: _openDrawer),
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

enum _MainScreen { timeline, calendar, media, analytics, settings, help, about }
