import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/diary_entry.dart';
import 'diary_entry_store.dart';

class SqliteDiaryEntryStore implements DiaryEntryStore {
  static const _databaseName = 'diary_entries.db';
  static const _databaseVersion = 4;
  static const _entriesTable = 'entries';

  final String? databasePath;
  final sqflite.DatabaseFactory? databaseFactory;

  sqflite.Database? _database;

  SqliteDiaryEntryStore({this.databasePath, this.databaseFactory});

  @override
  Future<List<DiaryEntry>> loadEntries() async {
    final db = await _openDatabase();
    final rows = await db.query(_entriesTable, orderBy: 'date DESC');
    return rows.map(_entryFromRow).toList();
  }

  @override
  Future<void> upsertEntry(DiaryEntry entry) async {
    final db = await _openDatabase();
    await db.insert(
      _entriesTable,
      _entryToRow(entry),
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteEntry(String id) async {
    final db = await _openDatabase();
    await db.delete(_entriesTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> trashEntry(String id, bool isDeleted) async {
    final db = await _openDatabase();
    await db.update(
      _entriesTable,
      {
        'is_deleted': isDeleted ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> permanentlyDeleteEntry(String id) async {
    final db = await _openDatabase();
    await db.delete(_entriesTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> archiveEntry(String id, bool isArchived) async {
    final db = await _openDatabase();
    await db.update(
      _entriesTable,
      {
        'is_archived': isArchived ? 1 : 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> seedEntriesIfEmpty(List<DiaryEntry> entries) async {
    final db = await _openDatabase();
    final countRows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $_entriesTable',
    );
    final count = sqflite.Sqflite.firstIntValue(countRows) ?? 0;
    if (count > 0) return;

    final batch = db.batch();
    for (final entry in entries) {
      batch.insert(
        _entriesTable,
        _entryToRow(entry),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> saveEntries(List<DiaryEntry> entries) async {
    final db = await _openDatabase();
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert(
        _entriesTable,
        _entryToRow(entry),
        conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<sqflite.Database> _openDatabase() async {
    final existingDatabase = _database;
    if (existingDatabase != null) return existingDatabase;

    final factory = databaseFactory ?? sqflite.databaseFactory;
    final path =
        databasePath ?? p.join(await sqflite.getDatabasesPath(), _databaseName);

    _database = await factory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _createSchema,
        onUpgrade: _onUpgrade,
      ),
    );
    return _database!;
  }

  Future<void> _createSchema(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_entriesTable (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        location TEXT,
        image_urls TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_entries_date ON $_entriesTable(date DESC)',
    );
  }

  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $_entriesTable ADD COLUMN is_archived INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $_entriesTable ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $_entriesTable ADD COLUMN updated_at TEXT');
      await db.execute(
        'UPDATE $_entriesTable SET updated_at = date WHERE updated_at IS NULL',
      );
    }
  }

  Map<String, Object?> _entryToRow(DiaryEntry entry) {
    return {
      'id': entry.id,
      'date': entry.date.toIso8601String(),
      'title': entry.title,
      'content': entry.content,
      'mood': entry.mood,
      'location': entry.location,
      'image_urls': jsonEncode(entry.imageUrls),
      'is_archived': entry.isArchived ? 1 : 0,
      'is_deleted': entry.isDeleted ? 1 : 0,
      'updated_at': entry.updatedAt.toIso8601String(),
    };
  }

  DiaryEntry _entryFromRow(Map<String, Object?> row) {
    final dateStr = row['date']! as String;
    final updatedAtStr = row['updated_at'] as String?;
    return DiaryEntry(
      id: row['id']! as String,
      date: DateTime.parse(dateStr),
      title: row['title']! as String,
      content: row['content']! as String,
      mood: row['mood']! as String,
      location: row['location'] as String?,
      imageUrls: (jsonDecode(row['image_urls']! as String) as List<dynamic>)
          .map((item) => item as String)
          .toList(),
      isArchived: (row['is_archived'] as int? ?? 0) == 1,
      isDeleted: (row['is_deleted'] as int? ?? 0) == 1,
      updatedAt: updatedAtStr != null
          ? DateTime.parse(updatedAtStr)
          : DateTime.parse(dateStr),
    );
  }
}
