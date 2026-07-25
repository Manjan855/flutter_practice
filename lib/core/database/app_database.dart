import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _database;
  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'flutter_practice.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE products(id INTEGER PRIMARY KEY, title TEXT , price REAL, thumbnail TEXT)''',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS products');
        await db.execute(
          ''' CREATE TABLE products(id INTEGER PRIMARY KEY, title TEXT, price REAL, thumbnail TEXT)''',
        );
      },
    );
  }
}
