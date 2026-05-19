import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

enum SyncOutcome { uploaded, downloaded, alreadyInSync }

class SyncResult {
  final SyncOutcome outcome;
  final DateTime? remoteModified;

  const SyncResult(this.outcome, this.remoteModified);
}

class DriveService {
  final GoogleSignIn _googleSignIn;
  static const _backupFileName = 'diary_backup.db';

  DriveService(this._googleSignIn);

  Future<SyncResult> sync() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final driveApi = drive.DriveApi(client);
    final query = "name = '$_backupFileName' and trashed = false";
    final fileList = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id,modifiedTime)',
    );

    final dbPath = p.join(await sqflite.getDatabasesPath(), 'diary_entries.db');
    final localFile = File(dbPath);
    final localExists = await localFile.exists();

    if (fileList.files == null || fileList.files!.isEmpty) {
      if (!localExists) throw Exception('Nothing to sync');
      await uploadBackup();
      return SyncResult(SyncOutcome.uploaded, DateTime.now().toUtc());
    }

    final remote = fileList.files!.first;
    final remoteModified = remote.modifiedTime;

    if (!localExists) {
      await downloadBackup();
      return SyncResult(SyncOutcome.downloaded, remoteModified);
    }

    final localModified = (await localFile.lastModified()).toUtc();
    if (remoteModified != null &&
        remoteModified.toUtc().isAfter(localModified.add(
              const Duration(seconds: 2),
            ))) {
      await downloadBackup();
      return SyncResult(SyncOutcome.downloaded, remoteModified);
    }

    if (remoteModified != null &&
        localModified.isAfter(remoteModified.toUtc().add(
              const Duration(seconds: 2),
            ))) {
      await uploadBackup();
      return SyncResult(SyncOutcome.uploaded, DateTime.now().toUtc());
    }

    return SyncResult(SyncOutcome.alreadyInSync, remoteModified);
  }

  Future<void> uploadBackup() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final driveApi = drive.DriveApi(client);

    // 1. Check if backup file already exists
    final query = "name = '$_backupFileName' and trashed = false";
    final fileList = await driveApi.files.list(q: query, spaces: 'drive');

    final dbPath = p.join(await sqflite.getDatabasesPath(), 'diary_entries.db');
    final file = File(dbPath);
    if (!await file.exists()) throw Exception('Database file not found');

    final media = drive.Media(file.openRead(), await file.length());
    final driveFile = drive.File()..name = _backupFileName;

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      // Update existing file
      final existingFileId = fileList.files!.first.id!;
      await driveApi.files.update(
        driveFile,
        existingFileId,
        uploadMedia: media,
      );
      print('Backup updated on Google Drive');
    } else {
      // Create new file
      await driveApi.files.create(driveFile, uploadMedia: media);
      print('New backup created on Google Drive');
    }
  }

  Future<void> downloadBackup() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('User not authenticated');

    final driveApi = drive.DriveApi(client);

    // 1. Find the backup file
    final query = "name = '$_backupFileName' and trashed = false";
    final fileList = await driveApi.files.list(q: query, spaces: 'drive');

    if (fileList.files == null || fileList.files!.isEmpty) {
      throw Exception('No backup found on Google Drive');
    }

    final fileId = fileList.files!.first.id!;

    // 2. Download the file
    final drive.Media downloadMedia =
        await driveApi.files.get(
              fileId,
              downloadOptions: drive.DownloadOptions.fullMedia,
            )
            as drive.Media;

    final dbPath = p.join(await sqflite.getDatabasesPath(), 'diary_entries.db');
    final file = File(dbPath);

    final IOSink sink = file.openWrite();
    await sink.addStream(downloadMedia.stream);
    await sink.close();

    print('Backup downloaded and restored');
  }
}
