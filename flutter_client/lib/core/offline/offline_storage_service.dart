import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineStorageService {
  static final OfflineStorageService _instance =
      OfflineStorageService._internal();
  factory OfflineStorageService() => _instance;
  OfflineStorageService._internal();

  Database? _database;
  final Map<String, Map<String, dynamic>> _webCache = {};

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Sqflite is not available on web');
    }

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

  Future<void> set(
    String key,
    Map<String, dynamic> data, {
    Duration? expiresIn,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiresIn != null ? now + expiresIn.inMilliseconds : null;

    if (kIsWeb) {
      _webCache[key] = {
        'value': jsonEncode(data),
        'expires_at': expiresAt,
        'created_at': now,
      };
      return;
    }

    final db = await database;

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
    final now = DateTime.now().millisecondsSinceEpoch;

    if (kIsWeb) {
      final row = _webCache[key];
      if (row == null) return null;

      final expiresAt = row['expires_at'] as int?;
      if (expiresAt != null && expiresAt < now) {
        _webCache.remove(key);
        return null;
      }

      return jsonDecode(row['value'] as String) as Map<String, dynamic>;
    }

    final db = await database;

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
    if (kIsWeb) {
      _webCache.remove(key);
      return;
    }

    final db = await database;
    await db.delete('offline_cache', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      _webCache.clear();
      return;
    }

    final db = await database;
    await db.delete('offline_cache');
  }

  Future<void> clearExpired() async {
    if (kIsWeb) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiredKeys = _webCache.entries
          .where((entry) {
            final expiresAt = entry.value['expires_at'] as int?;
            return expiresAt != null && expiresAt < now;
          })
          .map((entry) => entry.key)
          .toList();
      for (final key in expiredKeys) {
        _webCache.remove(key);
      }
      return;
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete('offline_cache', where: 'expires_at < ?', whereArgs: [now]);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    if (kIsWeb) {
      await clearExpired();
      return _webCache.values
          .map(
            (row) => jsonDecode(row['value'] as String) as Map<String, dynamic>,
          )
          .toList();
    }

    final db = await database;
    final results = await db.query('offline_cache', orderBy: 'created_at ASC');
    return results
        .map(
          (row) => jsonDecode(row['value'] as String) as Map<String, dynamic>,
        )
        .toList();
  }
}
