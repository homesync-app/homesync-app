import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

enum QueueStatus { pending, processing, completed, failed }

class QueuedRequest {
  final int? id;
  final String method;
  final String endpoint;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;
  final QueueStatus status;
  final int retryCount;
  final String? error;
  final DateTime createdAt;
  final DateTime? processedAt;

  QueuedRequest({
    this.id,
    required this.method,
    required this.endpoint,
    this.body,
    this.headers,
    this.status = QueueStatus.pending,
    this.retryCount = 0,
    this.error,
    DateTime? createdAt,
    this.processedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'method': method,
      'endpoint': endpoint,
      'body': body != null ? jsonEncode(body) : null,
      'headers': headers != null ? jsonEncode(headers) : null,
      'status': status.name,
      'retry_count': retryCount,
      'error': error,
      'created_at': createdAt.millisecondsSinceEpoch,
      'processed_at': processedAt?.millisecondsSinceEpoch,
    };
  }

  factory QueuedRequest.fromMap(Map<String, dynamic> map) {
    return QueuedRequest(
      id: map['id'] as int?,
      method: map['method'] as String,
      endpoint: map['endpoint'] as String,
      body: map['body'] != null ? jsonDecode(map['body'] as String) as Map<String, dynamic> : null,
      headers: map['headers'] != null ? Map<String, String>.from(jsonDecode(map['headers'] as String)) : null,
      status: QueueStatus.values.firstWhere((e) => e.name == map['status']),
      retryCount: map['retry_count'] as int? ?? 0,
      error: map['error'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      processedAt: map['processed_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['processed_at'] as int) 
          : null,
    );
  }

  QueuedRequest copyWith({
    int? id,
    String? method,
    String? endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    QueueStatus? status,
    int? retryCount,
    String? error,
    DateTime? createdAt,
    DateTime? processedAt,
  }) {
    return QueuedRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      endpoint: endpoint ?? this.endpoint,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}

class OfflineQueueService {
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'homesync_queue.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE request_queue (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            endpoint TEXT NOT NULL,
            body TEXT,
            headers TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            retry_count INTEGER DEFAULT 0,
            error TEXT,
            created_at INTEGER NOT NULL,
            processed_at INTEGER
          )
        ''');
      },
    );
  }

  Future<int> enqueue(QueuedRequest request) async {
    final db = await database;
    return db.insert('request_queue', {
      'method': request.method,
      'endpoint': request.endpoint,
      'body': request.body != null ? jsonEncode(request.body) : null,
      'headers': request.headers != null ? jsonEncode(request.headers) : null,
      'status': request.status.name,
      'retry_count': request.retryCount,
      'error': request.error,
      'created_at': request.createdAt.millisecondsSinceEpoch,
    });
  }

  Future<List<QueuedRequest>> getPending() async {
    final db = await database;
    final results = await db.query(
      'request_queue',
      where: 'status = ?',
      whereArgs: [QueueStatus.pending.name],
      orderBy: 'created_at ASC',
    );
    return results.map((row) => QueuedRequest.fromMap(row)).toList();
  }

  Future<QueuedRequest?> getNext() async {
    final db = await database;
    final results = await db.query(
      'request_queue',
      where: 'status = ?',
      whereArgs: [QueueStatus.pending.name],
      orderBy: 'created_at ASC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return QueuedRequest.fromMap(results.first);
  }

  Future<void> markProcessing(int id) async {
    final db = await database;
    await db.update(
      'request_queue',
      {'status': QueueStatus.processing.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markCompleted(int id) async {
    final db = await database;
    await db.update(
      'request_queue',
      {
        'status': QueueStatus.completed.name,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markFailed(int id, String error, {int? retryCount}) async {
    final db = await database;
    await db.update(
      'request_queue',
      {
        'status': QueueStatus.failed.name,
        'error': error,
        'retry_count': retryCount ?? 0,
        'processed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> incrementRetry(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE request_queue SET retry_count = retry_count + 1, status = ? WHERE id = ?',
      [QueueStatus.pending.name, id],
    );
  }

  Future<void> remove(int id) async {
    final db = await database;
    await db.delete('request_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCompleted() async {
    final db = await database;
    await db.delete(
      'request_queue',
      where: 'status = ?',
      whereArgs: [QueueStatus.completed.name],
    );
  }

  Future<int> getQueueLength() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM request_queue WHERE status = ?',
      [QueueStatus.pending.name],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> requeueFailed() async {
    final db = await database;
    await db.update(
      'request_queue',
      {'status': QueueStatus.pending.name},
      where: 'status = ? AND retry_count < ?',
      whereArgs: [QueueStatus.failed.name, 3],
    );
  }
}
