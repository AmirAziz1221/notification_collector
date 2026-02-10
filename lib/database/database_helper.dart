import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

/// Database helper for managing notification data storage
/// Uses SQLite with separate columns for truncated and full messages
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database schema
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE notifications (
        id $idType,
        package_name $textType,
        sender_name $textType,
        truncated_message $textType,
        full_message $textType,
        message_type $textType,
        timestamp $intType
      )
    ''');

    await db
        .execute('CREATE INDEX idx_timestamp ON notifications(timestamp DESC)');
    await db.execute(
        'CREATE INDEX idx_message_type ON notifications(message_type)');
  }

  /// Insert a new notification
  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await database;
    final result = await db.query('notifications', orderBy: 'timestamp DESC');
    return result.map((map) => NotificationModel.fromMap(map)).toList();
  }

  /// Get notifications with pagination
  Future<List<NotificationModel>> getNotifications({
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await database;
    final result = await db.query(
      'notifications',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((map) => NotificationModel.fromMap(map)).toList();
  }

  /// Get notification count
  Future<int> getNotificationCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM notifications');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get statistics
  Future<Map<String, int>> getStatistics() async {
    final db = await database;

    final totalResult =
        await db.rawQuery('SELECT COUNT(*) as count FROM notifications');
    final total = Sqflite.firstIntValue(totalResult) ?? 0;

    final typeResult = await db.rawQuery('''
      SELECT message_type, COUNT(*) as count 
      FROM notifications 
      GROUP BY message_type
    ''');

    final fullMessageResult = await db.rawQuery('''
      SELECT COUNT(*) as count 
      FROM notifications 
      WHERE full_message != 'NOT_AVAILABLE'
    ''');
    final fullMessageCount = Sqflite.firstIntValue(fullMessageResult) ?? 0;

    Map<String, int> stats = {
      'total': total,
      'with_full_message': fullMessageCount,
      'without_full_message': total - fullMessageCount,
    };

    for (var row in typeResult) {
      stats[row['message_type'] as String] = row['count'] as int;
    }

    return stats;
  }

  /// Delete all notifications
  Future<int> deleteAllNotifications() async {
    final db = await database;
    return await db.delete('notifications');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
