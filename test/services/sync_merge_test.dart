import 'package:flutter_test/flutter_test.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/data/diary_entry_store.dart';

void main() {
  group('DiaryEntryStore.merge', () {
    final baseTime = DateTime(2026, 5, 19, 12, 0);

    test('only local entries should return local entries', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Local Title',
          content: 'Local Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];
      final remote = <DiaryEntry>[];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Local Title');
    });

    test('only remote entries should return remote entries', () {
      final local = <DiaryEntry>[];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Remote Title',
          content: 'Remote Content',
          mood: '🚀',
          updatedAt: baseTime,
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.id, '1');
      expect(result.first.title, 'Remote Title');
    });

    test('both sides present: remote newer should keep remote', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Local Version',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Remote Version (Newer)',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.title, 'Remote Version (Newer)');
    });

    test('both sides present: local newer should keep local', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Local Version (Newer)',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Remote Version',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.title, 'Local Version (Newer)');
    });

    test('both tombstoned should keep the newer tombstone', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          isDeleted: true,
          updatedAt: baseTime,
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          isDeleted: true,
          location: 'Remote Loc',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.isDeleted, true);
      expect(result.first.location, 'Remote Loc');
    });

    test('one tombstoned, one edited: tombstone newer wins', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Edited Title',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          isDeleted: true,
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.isDeleted, true);
    });

    test('one tombstoned, one edited: edit newer wins', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Edited Title (Newer)',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          isDeleted: true,
          updatedAt: baseTime,
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.isDeleted, false);
      expect(result.first.title, 'Edited Title (Newer)');
    });

    test('both sides present: remote newer should keep remote tags', () {
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          tags: const ['old-tag'],
          updatedAt: baseTime,
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'Title',
          content: 'Content',
          mood: '😊',
          tags: const ['new-tag-1', 'new-tag-2'],
          updatedAt: baseTime.add(const Duration(minutes: 5)),
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      expect(result.first.tags, const ['new-tag-1', 'new-tag-2']);
    });

    test('identical updatedAt: tie-break by comparing serialized JSON lexically', () {
      // Local has title 'A', Remote has title 'B'
      // 'B' (remoteJson) vs 'A' (localJson) -> remoteJson is lexically larger/different and wins
      final local = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'A',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];
      final remote = [
        DiaryEntry(
          id: '1',
          date: baseTime,
          title: 'B',
          content: 'Content',
          mood: '😊',
          updatedAt: baseTime,
        ),
      ];

      final result = DiaryEntryStore.merge(local, remote);
      expect(result.length, 1);
      // We expect the one with larger lexically serialized JSON to win.
      // Let's print local and remote json:
      // local: {"id":"1","date":"...","title":"A",...}
      // remote: {"id":"1","date":"...","title":"B",...}
      // Since title "B" is lexically greater than "A", remote json is lexically greater and wins.
      expect(result.first.title, 'B');
    });
  });
}
