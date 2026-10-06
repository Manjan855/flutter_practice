import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite store shared by the app.
///
/// Kept as a lazy singleton: the first `await AppDatabase.instance` opens the
/// database, every later call reuses the same connection.
class AppDatabase {
  AppDatabase._();

  static Database? _database;

  static const String tableName = 'products';
  static const int schemaVersion = 3;

  static Future<Database> get instance async {
    return _database ??= await _open();
  }

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'flutter_practice.db');
    return openDatabase(
      path,
      version: schemaVersion,
      onCreate: (db, version) => _createSchema(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        // Pre-1.0 schema: drop and rebuild rather than write migrations for
        // every experiment. Replace with real migrations before shipping.
        await db.execute('DROP TABLE IF EXISTS $tableName');
        await _createSchema(db);
      },
    );
  }

  static Future<void> _createSchema(Database db) => db.execute(
    'CREATE TABLE $tableName('
    'id INTEGER PRIMARY KEY, '
    'title TEXT NOT NULL DEFAULT "", '
    'price REAL NOT NULL DEFAULT 0, '
    'thumbnail TEXT NOT NULL DEFAULT "")',
  );
}
