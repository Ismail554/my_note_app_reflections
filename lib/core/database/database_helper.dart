import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Singleton SQLite database helper for habits, todos, and reminders.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static const int _version = 1;
  static const String _dbName = 'reflections.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ─── Habits Table ────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        icon TEXT NOT NULL DEFAULT '🎯',
        color INTEGER NOT NULL DEFAULT 4294940467,
        target_days_per_week INTEGER NOT NULL DEFAULT 7,
        alarm_time TEXT,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ─── Habit Completions Table (separate for efficient querying) ────────
    await db.execute('''
      CREATE TABLE habit_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completed_date TEXT NOT NULL,
        UNIQUE(habit_id, completed_date),
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // ─── Todos Table ─────────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        due_date TEXT,
        completed_at TEXT,
        priority TEXT NOT NULL DEFAULT 'Medium',
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ─── Reminders Table ─────────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        trigger_date_time TEXT NOT NULL,
        is_scheduled INTEGER NOT NULL DEFAULT 1,
        is_alarm INTEGER NOT NULL DEFAULT 0,
        repeat_type TEXT NOT NULL DEFAULT 'none',
        notification_id INTEGER NOT NULL DEFAULT 0,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // ─── Indexes for performance ─────────────────────────────────────────
    await db.execute(
      'CREATE INDEX idx_habit_completions_date ON habit_completions (completed_date)',
    );
    await db.execute(
      'CREATE INDEX idx_habit_completions_habit ON habit_completions (habit_id)',
    );
    await db.execute(
      'CREATE INDEX idx_todos_user ON todos (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_reminders_user ON reminders (user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_todos_completed ON todos (is_completed)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  GENERIC CRUD HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List<Object?> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Close DB (for testing or cleanup)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
