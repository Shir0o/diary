import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/diary_entry_store.dart';
import 'data/sqlite_diary_entry_store.dart';
import 'screens/timeline_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/new_entry_screen.dart';
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
  int _currentIndex = 0;
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

  void _onItemSelected(int index) {
    setState(() {
      if (index == 0) _currentIndex = 0; // Timeline
      if (index == 1) _currentIndex = 1; // Calendar
      if (index == 3) _currentIndex = 2; // Analytics
      if (index == 4) _currentIndex = 3; // Settings
    });
    Navigator.of(context).pop(); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideDrawer(
        onItemSelected: _onItemSelected,
        selectedIndex: _currentIndex == 0
            ? 0
            : (_currentIndex == 1 ? 1 : (_currentIndex == 2 ? 3 : 4)),
      ),
      body: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    if (_isLoadingEntries) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return switch (_currentIndex) {
      0 => TimelineScreen(
        entries: _entries,
        onMenuPressed: _openDrawer,
        onAddEntry: _createEntry,
        onEditEntry: _editEntry,
      ),
      1 => CalendarScreen(
        entries: _entries,
        onMenuPressed: _openDrawer,
        onEditEntry: _editEntry,
      ),
      2 => AnalyticsScreen(entries: _entries, onMenuPressed: _openDrawer),
      _ => SettingsScreen(onMenuPressed: _openDrawer),
    };
  }
}
