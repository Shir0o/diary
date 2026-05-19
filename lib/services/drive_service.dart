import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

class DriveService {
  final GoogleSignIn _googleSignIn;
  static const _backupFileName = 'diary_backup.db';

  DriveService(this._googleSignIn);

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
