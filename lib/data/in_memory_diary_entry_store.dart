import '../models/diary_entry.dart';
import 'diary_entry_store.dart';

class InMemoryDiaryEntryStore implements DiaryEntryStore {
  final List<DiaryEntry> _entries;

  InMemoryDiaryEntryStore([List<DiaryEntry> entries = const []])
    : _entries = List.of(entries);

  @override
  Future<List<DiaryEntry>> loadEntries() async {
    return List.of(_entries)..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> upsertEntry(DiaryEntry entry) async {
    final index = _entries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _entries.add(entry);
    } else {
      _entries[index] = entry;
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries) async {
    if (_entries.isNotEmpty) return;
    _entries.addAll(entries);
  }

  @override
  Future<void> close() async {}
}
