import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineDatabase {
  static final OfflineDatabase instance = OfflineDatabase._init();
  static Database? _database;

  OfflineDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('offline_lessons.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloaded_lessons (
        id INTEGER PRIMARY KEY,
        lesson_id INTEGER UNIQUE,
        title TEXT,
        local_video_path TEXT,
        direct_hls_url TEXT,
        is_completed INTEGER,
        download_id TEXT,
        download_status INTEGER,
        download_progress INTEGER,
        file_size INTEGER,
        created_at TEXT
      )
    ''');
  }

  Future<int> insertDownload(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('downloaded_lessons', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllDownloads() async {
    final db = await instance.database;
    return await db.query('downloaded_lessons', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getDownloadByLessonId(int lessonId) async {
    final db = await instance.database;
    final results = await db.query(
      'downloaded_lessons',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    if (results.isNotEmpty) return results.first;
    return null;
  }

  Future<int> updateDownloadStatus(String downloadId, int status, int progress) async {
    final db = await instance.database;
    return await db.update(
      'downloaded_lessons',
      {'download_status': status, 'download_progress': progress},
      where: 'download_id = ?',
      whereArgs: [downloadId],
    );
  }

  Future<int> deleteDownload(int lessonId) async {
    final db = await instance.database;
    return await db.delete(
      'downloaded_lessons',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
