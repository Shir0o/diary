import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:diary/services/drive_service.dart';
import 'package:diary/models/diary_entry.dart';
import 'package:diary/data/in_memory_diary_entry_store.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  group('Sync Integration Test (HTTP Mock)', () {
    late MockGoogleSignIn mockGoogleSignIn;
    late MockClient mockClient;

    // Remote in-memory state representing Google Drive
    String? remoteJsonl;
    String remoteEtag = 'etag-0';
    String remoteVersion = '0';
    DateTime remoteModifiedTime = DateTime(2026, 5, 19, 12, 0);
    bool remoteExists = false;

    // A counter to inject failures for testing optimistic concurrency retry
    int inject412Count = 0;

    String extractMediaFromMultipart(String body) {
      final encodingMarker = 'Content-Transfer-Encoding: base64';
      final markerIndex = body.indexOf(encodingMarker);
      if (markerIndex == -1) {
        return body;
      }

      final startOfContent = body.indexOf('\r\n\r\n', markerIndex);
      final isCRLF = startOfContent != -1;
      final bodyStartIndex = isCRLF
          ? startOfContent + 4
          : body.indexOf('\n\n', markerIndex) + 2;

      if (bodyStartIndex < 2) return body;

      final contentPart = body.substring(bodyStartIndex);
      final boundaryIndex = contentPart.indexOf(isCRLF ? '\r\n--' : '\n--');
      if (boundaryIndex == -1) {
        return utf8.decode(base64.decode(contentPart.trim()));
      }

      final base64Content = contentPart.substring(0, boundaryIndex).trim();
      return utf8.decode(base64.decode(base64Content));
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockGoogleSignIn = MockGoogleSignIn();

      remoteJsonl = null;
      remoteEtag = 'etag-0';
      remoteVersion = '0';
      remoteModifiedTime = DateTime(2026, 5, 19, 12, 0);
      remoteExists = false;
      inject412Count = 0;

      mockClient = MockClient((request) async {
        final uri = request.url;
        final path = uri.path;
        final method = request.method;

        if (method == 'GET' && path == '/drive/v3/files') {
          final q = uri.queryParameters['q'] ?? '';
          if (q.contains('diary.jsonl')) {
            if (remoteExists) {
              return http.Response(
                json.encode({
                  'kind': 'drive#fileList',
                  'files': [
                    {
                      'id': 'file-jsonl-id',
                      'name': 'diary.jsonl',
                      'mimeType': 'text/plain',
                      'version': remoteVersion,
                      'modifiedTime': remoteModifiedTime.toIso8601String(),
                    },
                  ],
                }),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              );
            } else {
              return http.Response(
                json.encode({'kind': 'drive#fileList', 'files': []}),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              );
            }
          }
          return http.Response(
            '{"files":[]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (method == 'GET' && path == '/drive/v3/files/file-jsonl-id') {
          final alt = uri.queryParameters['alt'];
          if (alt == 'media') {
            return http.Response(
              remoteJsonl ?? '',
              200,
              headers: {
                'content-type': 'text/plain; charset=utf-8',
                'etag': remoteEtag,
              },
            );
          }
          return http.Response(
            json.encode({
              'id': 'file-jsonl-id',
              'name': 'diary.jsonl',
              'version': remoteVersion,
              'modifiedTime': remoteModifiedTime.toIso8601String(),
            }),
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'etag': remoteEtag,
            },
          );
        }

        if (method == 'POST' && path == '/upload/drive/v3/files') {
          remoteJsonl = extractMediaFromMultipart(request.body);
          remoteExists = true;
          remoteVersion = '1';
          remoteEtag = 'etag-1';
          remoteModifiedTime = DateTime.now().toUtc();
          return http.Response(
            json.encode({
              'id': 'file-jsonl-id',
              'name': 'diary.jsonl',
              'version': remoteVersion,
              'modifiedTime': remoteModifiedTime.toIso8601String(),
            }),
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'etag': remoteEtag,
            },
          );
        }

        if (method == 'PATCH' &&
            path == '/upload/drive/v3/files/file-jsonl-id') {
          if (inject412Count > 0) {
            inject412Count--;
            return http.Response('Precondition Failed', 412);
          }
          final ifMatch = request.headers['If-Match'];
          if (ifMatch != null && ifMatch != remoteEtag) {
            return http.Response('Precondition Failed', 412);
          }
          remoteJsonl = extractMediaFromMultipart(request.body);
          final currentVer = int.parse(remoteVersion);
          remoteVersion = '${currentVer + 1}';
          remoteEtag = 'etag-$remoteVersion';
          remoteModifiedTime = DateTime.now().toUtc();
          return http.Response(
            json.encode({
              'id': 'file-jsonl-id',
              'name': 'diary.jsonl',
              'version': remoteVersion,
              'modifiedTime': remoteModifiedTime.toIso8601String(),
            }),
            200,
            headers: {
              'content-type': 'application/json; charset=utf-8',
              'etag': remoteEtag,
            },
          );
        }

        return http.Response('Not Found', 404);
      });
    });

    test('interleaved multi-device writes should converge successfully', () async {
      final storeA = InMemoryDiaryEntryStore();
      final storeB = InMemoryDiaryEntryStore();

      final serviceA = DriveService(
        mockGoogleSignIn,
        testClient: mockClient,
        preferencePrefix: 'a_',
      );
      final serviceB = DriveService(
        mockGoogleSignIn,
        testClient: mockClient,
        preferencePrefix: 'b_',
      );

      // --- Time T0: Device A writes Entry 1 ---
      final entry1 = DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 5, 19, 10, 0),
        title: 'Entry 1 - A',
        content: 'Content from A',
        mood: '😊',
        updatedAt: DateTime.now().toUtc(),
      );
      await storeA.upsertEntry(entry1);

      await Future.delayed(const Duration(milliseconds: 2));

      // Sync A -> Uploads Entry 1
      final resA1 = await serviceA.sync(storeA);
      expect(resA1.outcome, SyncOutcome.uploaded);
      expect(remoteExists, true);

      await Future.delayed(const Duration(milliseconds: 2));

      // --- Time T1: Device B syncs ---
      // Sync B -> Downloads Entry 1
      final resB1 = await serviceB.sync(storeB);
      expect(
        resB1.outcome,
        SyncOutcome.uploaded,
      ); // Initial upload of B's empty store merged with remote
      final entriesB1 = await storeB.loadEntries();
      expect(entriesB1.length, 1);
      expect(entriesB1.first.title, 'Entry 1 - A');

      await Future.delayed(const Duration(milliseconds: 2));

      // --- Time T2: Device B writes Entry 2, Device A writes newer Entry 1 ---
      final entry2 = DiaryEntry(
        id: 'entry-2',
        date: DateTime(2026, 5, 19, 10, 5),
        title: 'Entry 2 - B',
        content: 'Content from B',
        mood: '🚀',
        updatedAt: DateTime.now().toUtc(),
      );
      await storeB.upsertEntry(entry2);

      final entry1Newer = entry1.copyWith(
        title: 'Entry 1 - A (Edited)',
        updatedAt: DateTime.now().toUtc(),
      );
      await storeA.upsertEntry(entry1Newer);

      await Future.delayed(const Duration(milliseconds: 2));

      // Sync B -> uploads Entry 1 (original) + Entry 2
      final resB2 = await serviceB.sync(storeB);
      expect(resB2.outcome, SyncOutcome.uploaded);

      await Future.delayed(const Duration(milliseconds: 2));

      // Sync A -> downloads remote, merges (local newer entry 1 wins over remote old entry 1, remote entry 2 imported), uploads merged.
      final resA2 = await serviceA.sync(storeA);
      expect(resA2.outcome, SyncOutcome.uploaded);

      final entriesA2 = await storeA.loadEntries();
      expect(entriesA2.length, 2);
      expect(
        entriesA2.firstWhere((e) => e.id == 'entry-1').title,
        'Entry 1 - A (Edited)',
      );
      expect(
        entriesA2.firstWhere((e) => e.id == 'entry-2').title,
        'Entry 2 - B',
      );

      await Future.delayed(const Duration(milliseconds: 2));

      // --- Time T3: Device B syncs again to catch up ---
      final resB3 = await serviceB.sync(storeB);
      expect(resB3.outcome, SyncOutcome.uploaded);

      final entriesB3 = await storeB.loadEntries();
      expect(entriesB3.length, 2);
      expect(
        entriesB3.firstWhere((e) => e.id == 'entry-1').title,
        'Entry 1 - A (Edited)',
      );
      expect(
        entriesB3.firstWhere((e) => e.id == 'entry-2').title,
        'Entry 2 - B',
      );
    });

    test('optimistic concurrency failure should retry and succeed', () async {
      final store = InMemoryDiaryEntryStore();
      final service = DriveService(mockGoogleSignIn, testClient: mockClient);

      final entry = DiaryEntry(
        id: 'entry-1',
        date: DateTime(2026, 5, 19, 10, 0),
        title: 'Title',
        content: 'Content',
        mood: '😊',
        updatedAt: DateTime.now().toUtc(),
      );
      await store.upsertEntry(entry);

      // First sync works fine
      await service.sync(store);

      await Future.delayed(const Duration(milliseconds: 2));

      // Make a local change
      final updated = entry.copyWith(
        title: 'Updated',
        updatedAt: DateTime.now().toUtc(),
      );
      await store.upsertEntry(updated);

      // Force 1 retry during the update call
      inject412Count = 1;

      // Sync should succeed eventually due to retry loop
      final res = await service.sync(store);
      expect(res.outcome, SyncOutcome.uploaded);
      expect(
        inject412Count,
        0,
      ); // verify the failure was injected and caught/retried
    });
  });
}
