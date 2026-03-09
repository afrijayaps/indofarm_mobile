import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._(this.database);

  final Database database;

  static Future<LocalDatabase> open() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      join(dbPath, 'indofarm_mobile.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE recording_drafts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            farm_id INTEGER NOT NULL,
            payload TEXT NOT NULL,
            status TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE sync_jobs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            draft_id INTEGER NOT NULL,
            status TEXT NOT NULL,
            error_message TEXT
          )
        ''');
      },
    );
    return LocalDatabase._(db);
  }
}
