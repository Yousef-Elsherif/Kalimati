import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_seeder.dart';

/// Open (or create) the Floor database and run the seeder once.
/// Returns a ready-to-use [AppDatabase].
AppDatabase? _appDatabase;

Future<AppDatabase> openAndSeedDatabase() async {
  if (_appDatabase != null) return _appDatabase!;

  final db = await $FloorAppDatabase
      .databaseBuilder('kalimaiti_app.db')
      .build();
  // Run seeding using the existing DB instance. This is idempotent.
  await DatabaseSeederService.seedDatabaseWith(db);
  _appDatabase = db;
  return _appDatabase!;
}

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  // Return already-opened DB if present, otherwise open and seed.
  return _appDatabase ??= await openAndSeedDatabase();
});
