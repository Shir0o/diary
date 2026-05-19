import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:diary/data/sqlite_diary_entry_store.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('InMemoryDiaryEntryStore - deleteEntriesDeletedBefore', () {
    test('purges only entries deleted before the cutoff', () async {
      final now = DateTime.now();
      final store = InMemoryDiaryEntryStore([
        DiaryEntry(
          id: 'deleted-old',
          date: now.subtract(const Duration(days: 40)),
          title: 'Old Deleted',
          content: 'Content',
          mood: '😢',
          isDeleted: true,
          updatedAt: now.subtract(const Duration(days: 35)),
        ),
        DiaryEntry(
          id: 'deleted-new',
          date: now.subtract(const Duration(days: 5)),
          title: 'New Deleted',
          content: 'Content',
          mood: '😢',
          isDeleted: true,
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        DiaryEntry(
          id: 'archived-old',
          date: now.subtract(const Duration(days: 40)),
          title: 'Old Archived',
          content: 'Content',
          mood: '📦',
          isArchived: true,
          updatedAt: now.subtract(const Duration(days: 35)),
        ),
        DiaryEntry(
          id: 'normal-old',
          date: now.subtract(const Duration(days: 40)),
          title: 'Old Normal',
          content: 'Content',
          mood: '📝',
          updatedAt: now.subtract(const Duration(days: 35)),
        ),
      ]);

      final cutoff = now.subtract(const Duration(days: 30));
      await store.deleteEntriesDeletedBefore(cutoff);

      final entries = await store.loadEntries();
      final ids = entries.map((e) => e.id).toList();

      expect(ids, contains('deleted-new'));
      expect(ids, contains('archived-old'));
      expect(ids, contains('normal-old'));
      expect(ids, isNot(contains('deleted-old')));
    });
  });

  group('SqliteDiaryEntryStore - deleteEntriesDeletedBefore', () {
    late SqliteDiaryEntryStore store;

    setUp(() {
      sqfliteFfiInit();
      store = SqliteDiaryEntryStore(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
    });

    tearDown(() async {
      await store.close();
    });

    test('purges only entries deleted before the cutoff', () async {
      final now = DateTime.now().toUtc();

      final e1 = DiaryEntry(
        id: 'deleted-old',
        date: now.subtract(const Duration(days: 40)),
        title: 'Old Deleted',
        content: 'Content',
        mood: '😢',
        isDeleted: true,
        updatedAt: now.subtract(const Duration(days: 35)),
      );
      final e2 = DiaryEntry(
        id: 'deleted-new',
        date: now.subtract(const Duration(days: 5)),
        title: 'New Deleted',
        content: 'Content',
        mood: '😢',
        isDeleted: true,
        updatedAt: now.subtract(const Duration(days: 2)),
      );
      final e3 = DiaryEntry(
        id: 'archived-old',
        date: now.subtract(const Duration(days: 40)),
        title: 'Old Archived',
        content: 'Content',
        mood: '📦',
        isArchived: true,
        updatedAt: now.subtract(const Duration(days: 35)),
      );
      final e4 = DiaryEntry(
        id: 'normal-old',
        date: now.subtract(const Duration(days: 40)),
        title: 'Old Normal',
        content: 'Content',
        mood: '📝',
        updatedAt: now.subtract(const Duration(days: 35)),
      );

      await store.upsertEntry(e1);
      await store.upsertEntry(e2);
      await store.upsertEntry(e3);
      await store.upsertEntry(e4);

      final cutoff = now.subtract(const Duration(days: 30));
      await store.deleteEntriesDeletedBefore(cutoff);

      final entries = await store.loadEntries();
      final ids = entries.map((e) => e.id).toList();

      expect(ids, contains('deleted-new'));
      expect(ids, contains('archived-old'));
      expect(ids, contains('normal-old'));
      expect(ids, isNot(contains('deleted-old')));
    });
  });
}
