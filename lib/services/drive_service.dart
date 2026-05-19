import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:http/http.dart' as http;
import '../data/diary_entry_store.dart';
import '../data/sqlite_diary_entry_store.dart';
import '../models/diary_entry.dart';

enum SyncOutcome { uploaded, downloaded, alreadyInSync }

class SyncResult {
  final SyncOutcome outcome;
  final DateTime? remoteModified;

  const SyncResult(this.outcome, this.remoteModified);
}

class EtagClient extends http.BaseClient {
  final http.Client _inner;
  final String? _etag;
  String? responseEtag;

  EtagClient(this._inner, [this._etag]);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_etag != null && (request.method == 'PATCH' || request.method == 'PUT')) {
      request.headers['If-Match'] = _etag!;
    }
    final response = await _inner.send(request);
    final captured = response.headers['etag'] ?? response.headers['ETag'];
    if (captured != null) {
      responseEtag = captured;
    }
    return response;
  }
}

class DriveService {
  final GoogleSignIn _googleSignIn;
  final http.Client? _testClient;
  final String _prefPrefix;
  static const _backupFileName = 'diary.jsonl';
  static const _legacyBackupFileName = 'diary_backup.db';

  Future<SyncResult>? _inFlight;

  DriveService(this._googleSignIn, {http.Client? testClient, String preferencePrefix = ''})
      : _testClient = testClient,
        _prefPrefix = preferencePrefix;

  Future<SyncResult> sync(DiaryEntryStore entryStore) {
    if (_inFlight != null) {
      return _inFlight!;
    }
    _inFlight = _runSyncWithRetry(entryStore).whenComplete(() {
      _inFlight = null;
    });
    return _inFlight!;
  }

  Future<SyncResult> _runSyncWithRetry(DiaryEntryStore entryStore) async {
    int attempts = 0;
    while (attempts < 3) {
      attempts++;
      try {
        return await _runSync(entryStore);
      } catch (e) {
        if (e is drive.DetailedApiRequestError && e.status == 412) {
          // Conflict / concurrency error: retry
          await Future.delayed(const Duration(milliseconds: 500));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Sync failed after retries');
  }

  Future<SyncResult> _runSync(DiaryEntryStore entryStore) async {
    final rawClient = await _getAuthenticatedClient();
    final prefs = await SharedPreferences.getInstance();
    final lastRemoteEtag = prefs.getString('${_prefPrefix}last_remote_etag');
    final client = EtagClient(rawClient, lastRemoteEtag);
    final driveApi = drive.DriveApi(client);

    final lastSyncedIso = prefs.getString('${_prefPrefix}last_synced_at');
    final lastRemoteVersion = prefs.getString('${_prefPrefix}last_remote_version');
    final lastSyncedAt = lastSyncedIso != null
        ? DateTime.parse(lastSyncedIso)
        : DateTime.fromMillisecondsSinceEpoch(0);

    // 1. Fetch remote file metadata
    final query = "name = '$_backupFileName' and trashed = false";
    final fileList = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id,modifiedTime,version)',
    );

    final hasRemote = fileList.files != null && fileList.files!.isNotEmpty;

    if (!hasRemote) {
      // Check for legacy backup
      final legacyQuery = "name = '$_legacyBackupFileName' and trashed = false";
      final legacyList = await driveApi.files.list(
        q: legacyQuery,
        spaces: 'drive',
        $fields: 'files(id,modifiedTime)',
      );

      final hasLegacy = legacyList.files != null && legacyList.files!.isNotEmpty;

      if (hasLegacy) {
        // Migration flow: download legacy, load entries, merge with local, save, and upload jsonl
        final legacyFile = legacyList.files!.first;
        final legacyFileId = legacyFile.id!;

        final tempPath = p.join(await sqflite.getDatabasesPath(), 'temp_import.db');
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        final drive.Media downloadMedia = await driveApi.files.get(
          legacyFileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final IOSink sink = tempFile.openWrite();
        await sink.addStream(downloadMedia.stream);
        await sink.close();

        // Load entries from legacy db
        final tempStore = SqliteDiaryEntryStore(
          databasePath: tempPath,
          databaseFactory: entryStore is SqliteDiaryEntryStore
              ? entryStore.databaseFactory
              : null,
        );
        final importedEntries = await tempStore.loadEntries();
        await tempStore.close();
        await tempFile.delete();

        // Merge with local
        final localEntries = await entryStore.loadEntries();
        final mergedEntries = DiaryEntryStore.merge(localEntries, importedEntries);
        await entryStore.saveEntries(mergedEntries);

        // Upload merged entries to new diary.jsonl file
        final result = await _uploadNewFile(client, mergedEntries);

        // Update sync state
        await prefs.setString('${_prefPrefix}last_synced_at', DateTime.now().toUtc().toIso8601String());
        if (client.responseEtag != null) {
          await prefs.setString('${_prefPrefix}last_remote_etag', client.responseEtag!);
        }
        if (result.version != null) {
          await prefs.setString('${_prefPrefix}last_remote_version', result.version!);
        }
        return SyncResult(SyncOutcome.uploaded, result.modifiedTime);
      } else {
        // No legacy file, no remote file -> upload local entries
        final localEntries = await entryStore.loadEntries();
        final result = await _uploadNewFile(client, localEntries);

        await prefs.setString('${_prefPrefix}last_synced_at', DateTime.now().toUtc().toIso8601String());
        if (client.responseEtag != null) {
          await prefs.setString('${_prefPrefix}last_remote_etag', client.responseEtag!);
        }
        if (result.version != null) {
          await prefs.setString('${_prefPrefix}last_remote_version', result.version!);
        }
        return SyncResult(SyncOutcome.uploaded, result.modifiedTime);
      }
    }

    final remoteFile = fileList.files!.first;
    final remoteFileId = remoteFile.id!;
    final remoteVersion = remoteFile.version;
    final remoteModified = remoteFile.modifiedTime;

    if (remoteVersion != null && remoteVersion == lastRemoteVersion) {
      // Remote unchanged since last sync.
      // Check if we have local changes: entries with updatedAt > lastSyncedAt
      final localEntries = await entryStore.loadEntries();
      final hasLocalChanges =
          localEntries.any((entry) => entry.updatedAt.isAfter(lastSyncedAt));

      if (!hasLocalChanges) {
        return SyncResult(SyncOutcome.alreadyInSync, remoteModified);
      }

      // Upload local entries (which are already merged since remote has not changed)
      final result = await _uploadWithEtag(
        client,
        remoteFileId,
        lastRemoteEtag ?? '',
        localEntries,
      );
      await prefs.setString('${_prefPrefix}last_synced_at', DateTime.now().toUtc().toIso8601String());
      if (client.responseEtag != null) {
        await prefs.setString('${_prefPrefix}last_remote_etag', client.responseEtag!);
      }
      if (result.version != null) {
        await prefs.setString('${_prefPrefix}last_remote_version', result.version!);
      }
      return SyncResult(SyncOutcome.uploaded, result.modifiedTime);
    }

    // Remote has changed! We must download, merge, write, and upload.
    final remoteMedia = await driveApi.files.get(
      remoteFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final remoteContent = await utf8.decodeStream(remoteMedia.stream);
    final remoteEntries = DiaryEntryStore.fromJSONL(remoteContent);

    final localEntries = await entryStore.loadEntries();
    final mergedEntries = DiaryEntryStore.merge(localEntries, remoteEntries);

    // Save to local database
    await entryStore.saveEntries(mergedEntries);

    // Upload merged entries back to Drive
    final result = await _uploadWithEtag(
      client,
      remoteFileId,
      client.responseEtag ?? lastRemoteEtag ?? '',
      mergedEntries,
    );

    await prefs.setString('${_prefPrefix}last_synced_at', DateTime.now().toUtc().toIso8601String());
    if (client.responseEtag != null) {
      await prefs.setString('${_prefPrefix}last_remote_etag', client.responseEtag!);
    }
    if (result.version != null) {
      await prefs.setString('${_prefPrefix}last_remote_version', result.version!);
    }
    return SyncResult(SyncOutcome.uploaded, result.modifiedTime);
  }

  Future<drive.File> _uploadNewFile(
    EtagClient client,
    List<DiaryEntry> entries,
  ) async {
    final driveApi = drive.DriveApi(client);
    final jsonl = DiaryEntryStore.toJSONL(entries);
    final bytes = utf8.encode(jsonl);
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final driveFile = drive.File()
      ..name = _backupFileName
      ..mimeType = 'text/plain';

    return await driveApi.files.create(driveFile, uploadMedia: media);
  }

  Future<drive.File> _uploadWithEtag(
    EtagClient client,
    String fileId,
    String etag,
    List<DiaryEntry> entries,
  ) async {
    final jsonl = DiaryEntryStore.toJSONL(entries);
    final bytes = utf8.encode(jsonl);
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final driveFile = drive.File()
      ..name = _backupFileName
      ..mimeType = 'text/plain';

    final updateClient = EtagClient(client._inner, etag);
    final updateDriveApi = drive.DriveApi(updateClient);
    final result = await updateDriveApi.files.update(
      driveFile,
      fileId,
      uploadMedia: media,
    );
    client.responseEtag = updateClient.responseEtag;
    return result;
  }

  Future<http.Client> _getAuthenticatedClient() async {
    if (_testClient != null) {
      return _testClient!;
    }
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('User not authenticated');
    return client;
  }
}
