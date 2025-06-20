import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('games.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increase version to trigger onUpgrade
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        enemies_defeated INTEGER NOT NULL,
        enemies_missed INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the enemies_missed column if upgrading from version 1
      await db.execute(
          'ALTER TABLE scores ADD COLUMN enemies_missed INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<int> insertScore(int score, int enemiesDefeated,
      [int enemiesMissed = 0]) async {
    final db = await database;
    final data = {
      'score': score,
      'enemies_defeated': enemiesDefeated,
      'enemies_missed': enemiesMissed,
      'date': DateTime.now().toIso8601String(),
    };
    return await db.insert('scores', data);
  }

  Future<List<Map<String, dynamic>>> getHighScores({int limit = 10}) async {
    final db = await database;
    return await db.query(
      'scores',
      orderBy: 'score DESC',
      limit: limit,
    );
  }

  // For development use only - delete the database to reset schema
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'games.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
