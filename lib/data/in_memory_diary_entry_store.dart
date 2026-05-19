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
  Future<void> trashEntry(String id, bool isDeleted) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        isDeleted: isDeleted,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> permanentlyDeleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
  }

  @override
  Future<void> archiveEntry(String id, bool isArchived) async {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        isArchived: isArchived,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deleteEntriesDeletedBefore(DateTime cutoff) async {
    _entries.removeWhere((e) => e.isDeleted && e.updatedAt.isBefore(cutoff));
  }

  @override
  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries) async {
    if (_entries.isNotEmpty) return;
    _entries.addAll(entries);
  }

  @override
  Future<void> saveEntries(List<DiaryEntry> entries) async {
    for (final entry in entries) {
      await upsertEntry(entry);
    }
  }

  @override
  Future<void> close() async {}
}
