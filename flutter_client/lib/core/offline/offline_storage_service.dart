import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance = OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'homesync_offline.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE offline_cache (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT UNIQUE NOT NULL,
            value TEXT NOT NULL,
            expires_at INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE INDEX idx_cache_key ON offline_cache(key)
        ''');
      },
    );
  }

  Future<void> set(String key, Map<String, dynamic> data, {Duration? expiresIn}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiresIn != null 
        ? now + expiresIn.inMilliseconds 
        : null;

    await db.insert(
      'offline_cache',
      {
        'key': key,
        'value': jsonEncode(data),
        'expires_at': expiresAt,
        'created_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> get(String key) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final results = await db.query(
      'offline_cache',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final expiresAt = row['expires_at'] as int?;
    
    if (expiresAt != null && expiresAt < now) {
      await db.delete('offline_cache', where: 'key = ?', whereArgs: [key]);
      return null;
    }

    return jsonDecode(row['value'] as String) as Map<String, dynamic>;
  }

  Future<void> delete(String key) async {
    final db = await database;
    await db.delete('offline_cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clear() async {
    final db = await database;
    await db.delete('offline_cache');
  }

  Future<void> clearExpired() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete('offline_cache', where: 'expires_at < ?', whereArgs: [now]);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await database;
    final results = await db.query('offline_cache', orderBy: 'created_at ASC');
    return results.map((row) => jsonDecode(row['value'] as String) as Map<String, dynamic>).toList();
  }
}
