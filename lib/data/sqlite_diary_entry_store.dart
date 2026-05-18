import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;

import '../models/diary_entry.dart';
import 'diary_entry_store.dart';

class SqliteDiaryEntryStore implements DiaryEntryStore {
  static const _databaseName = 'diary_entries.db';
  static const _databaseVersion = 1;
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
        image_urls TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_entries_date ON $_entriesTable(date DESC)',
    );
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
    };
  }

  DiaryEntry _entryFromRow(Map<String, Object?> row) {
    return DiaryEntry(
      id: row['id']! as String,
      date: DateTime.parse(row['date']! as String),
      title: row['title']! as String,
      content: row['content']! as String,
      mood: row['mood']! as String,
      location: row['location'] as String?,
      imageUrls: (jsonDecode(row['image_urls']! as String) as List<dynamic>)
          .map((item) => item as String)
          .toList(),
    );
  }
}
