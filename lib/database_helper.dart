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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        enemies_defeated INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertScore(int score, int enemiesDefeated) async {
    final db = await database;
    final data = {
      'score': score,
      'enemies_defeated': enemiesDefeated,
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
}
