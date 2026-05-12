import 'package:diary/data/sqlite_diary_entry_store.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
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

  test('seeds entries only when the database is empty', () async {
    final seedEntries = [
      DiaryEntry(
        id: 'older',
        date: DateTime(2026, 4, 23, 9),
        title: 'Older',
        content: 'Older content',
        mood: '📝',
      ),
      DiaryEntry(
        id: 'newer',
        date: DateTime(2026, 4, 24, 9),
        title: 'Newer',
        content: 'Newer content',
        mood: '🚀',
      ),
    ];

    await store.seedEntriesIfEmpty(seedEntries);
    await store.seedEntriesIfEmpty([
      DiaryEntry(
        id: 'ignored',
        date: DateTime(2026, 4, 25, 9),
        title: 'Ignored',
        content: 'Ignored content',
        mood: '☕',
      ),
    ]);

    final entries = await store.loadEntries();

    expect(entries.map((entry) => entry.id), ['newer', 'older']);
  });

  test('upserts an entry by id', () async {
    final original = DiaryEntry(
      id: 'entry-1',
      date: DateTime(2026, 4, 24, 9),
      title: 'Original',
      content: 'Original content',
      mood: '📝',
      location: 'Desk',
      imageUrls: const ['image-a'],
    );
    final updated = original.copyWith(
      title: 'Updated',
      content: 'Updated content',
      imageUrls: const ['image-b'],
    );

    await store.upsertEntry(original);
    await store.upsertEntry(updated);

    final entries = await store.loadEntries();

    expect(entries, hasLength(1));
    expect(entries.single.title, 'Updated');
    expect(entries.single.content, 'Updated content');
    expect(entries.single.location, 'Desk');
    expect(entries.single.imageUrls, ['image-b']);
  });
}
