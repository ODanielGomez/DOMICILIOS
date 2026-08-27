import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  DatabaseHelper._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'domifinanace.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE incomes (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, type TEXT NOT NULL, note TEXT, image_path TEXT, date TEXT NOT NULL, time TEXT NOT NULL DEFAULT \"00:00\", created_at TEXT NOT NULL)');
    await db.execute('CREATE TABLE expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, category TEXT NOT NULL, note TEXT, image_path TEXT, date TEXT NOT NULL, created_at TEXT NOT NULL)');
    await db.execute('CREATE TABLE savings (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL NOT NULL, note TEXT, type TEXT NOT NULL, date TEXT NOT NULL, created_at TEXT NOT NULL)');
    await db.execute('CREATE TABLE goals (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, target_amount REAL NOT NULL, period TEXT NOT NULL, start_date TEXT NOT NULL, end_date TEXT, is_active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)');
    await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
    await db.insert('settings', {'key': 'delivery_percentage', 'value': '10'});
    await db.insert('settings', {'key': 'theme_mode', 'value': 'system'});
    await db.insert('settings', {'key': 'daily_reminder', 'value': 'true'});
    await db.insert('settings', {'key': 'reminder_time', 'value': '20:00'});
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE incomes ADD COLUMN time TEXT NOT NULL DEFAULT \"00:00\"');
    }
  }
  Future<int> insert(String table, Map<String, dynamic> data) async { final db = await database; return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace); }
  Future<List<Map<String, dynamic>>> queryAll(String table) async { final db = await database; return await db.query(table, orderBy: 'date DESC'); }
  Future<List<Map<String, dynamic>>> queryByDateRange(String table, String start, String end) async { final db = await database; return await db.query(table, where: 'date >= ? AND date <= ?', whereArgs: [start, end], orderBy: 'date DESC'); }
  Future<int> update(String table, Map<String, dynamic> data, int id) async { final db = await database; return await db.update(table, data, where: 'id = ?', whereArgs: [id]); }
  Future<int> delete(String table, int id) async { final db = await database; return await db.delete(table, where: 'id = ?', whereArgs: [id]); }
  Future<String?> getSetting(String key) async { final db = await database; final r = await db.query('settings', where: 'key = ?', whereArgs: [key]); if (r.isEmpty) return null; return r.first['value'] as String?; }
  Future<void> setSetting(String key, String value) async { final db = await database; await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace); }
}
