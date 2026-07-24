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
    final path = join(dbPath, 'flutter_practice');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          
          '''CREATE TABLE products(id INTERGER PRIMARY KEY, tittle TEXT , price REAL, thumpnail TEXT)''',
        );
      },
    );
  }
}
