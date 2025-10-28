import '../app_database.dart';

class DatabaseHelper {
  static AppDatabase? _database;

  static Future<AppDatabase> getDatabase() async {
    if (_database != null) return _database!;

    _database = await $FloorAppDatabase
        .databaseBuilder('kalimaiti_app.db')
        .build();

    return _database!;
  }

  static Future<void> closeDatabase() async {
    await _database?.close();
    _database = null;
  }
}
