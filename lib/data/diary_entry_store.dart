import '../models/diary_entry.dart';

abstract class DiaryEntryStore {
  Future<List<DiaryEntry>> loadEntries();

  Future<void> upsertEntry(DiaryEntry entry);

  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries);

  Future<void> close();
}
