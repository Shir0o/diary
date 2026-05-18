import '../models/diary_entry.dart';

abstract class DiaryEntryStore {
  Future<List<DiaryEntry>> loadEntries();

  Future<void> upsertEntry(DiaryEntry entry);

  Future<void> deleteEntry(String id);

  Future<void> trashEntry(String id, bool isDeleted);

  Future<void> permanentlyDeleteEntry(String id);

  Future<void> archiveEntry(String id, bool isArchived);

  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries);

  Future<void> close();
}
