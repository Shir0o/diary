import 'dart:convert';
import '../models/diary_entry.dart';

abstract class DiaryEntryStore {
  Future<List<DiaryEntry>> loadEntries();

  Future<void> upsertEntry(DiaryEntry entry);

  Future<void> deleteEntry(String id);

  Future<void> trashEntry(String id, bool isDeleted);

  Future<void> permanentlyDeleteEntry(String id);

  Future<void> permanentlyDeleteEntries(List<String> ids);

  Future<void> archiveEntry(String id, bool isArchived);

  Future<void> deleteEntriesDeletedBefore(DateTime cutoff);

  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries);

  Future<void> saveEntries(List<DiaryEntry> entries);

  Future<void> close();

  static String toJSONL(List<DiaryEntry> entries) {
    return entries.map((entry) => jsonEncode(entry.toJson())).join('\n');
  }

  static List<DiaryEntry> fromJSONL(String jsonlContent) {
    if (jsonlContent.trim().isEmpty) return [];
    return jsonlContent
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map(
          (line) =>
              DiaryEntry.fromJson(jsonDecode(line) as Map<String, dynamic>),
        )
        .toList();
  }

  static List<DiaryEntry> merge(
    List<DiaryEntry> local,
    List<DiaryEntry> remote,
  ) {
    final Map<String, DiaryEntry> merged = {};

    for (final entry in local) {
      merged[entry.id] = entry;
    }

    for (final remoteEntry in remote) {
      final localEntry = merged[remoteEntry.id];
      if (localEntry == null) {
        merged[remoteEntry.id] = remoteEntry;
      } else {
        if (remoteEntry.updatedAt.isAfter(localEntry.updatedAt)) {
          merged[remoteEntry.id] = remoteEntry;
        } else if (localEntry.updatedAt.isAfter(remoteEntry.updatedAt)) {
          // Keep local
        } else {
          // Ties broken by comparing key fields first to avoid jsonEncode in most cases
          var cmp = remoteEntry.content.compareTo(localEntry.content);
          if (cmp == 0) {
            cmp = remoteEntry.title.compareTo(localEntry.title);
          }
          if (cmp == 0) {
            cmp = remoteEntry.mood.compareTo(localEntry.mood);
          }
          if (cmp == 0) {
            cmp = remoteEntry.date.toIso8601String().compareTo(
              localEntry.date.toIso8601String(),
            );
          }
          if (cmp == 0) {
            // Ultimate fallback to ensure full object comparison correctness
            final localJson = jsonEncode(localEntry.toJson());
            final remoteJson = jsonEncode(remoteEntry.toJson());
            cmp = remoteJson.compareTo(localJson);
          }
          if (cmp > 0) {
            merged[remoteEntry.id] = remoteEntry;
          }
        }
      }
    }

    return merged.values.toList();
  }
}
