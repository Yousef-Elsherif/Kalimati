import 'package:floor/floor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'database_seeder.dart';


AppDatabase? _appDatabase;

final _migration1to2 = Migration(1, 2, (database) async {
  await database.execute('DROP TABLE IF EXISTS `ResourceEntity`');
  await database.execute('DROP TABLE IF EXISTS `SentenceEntity`');
  await database.execute('DROP TABLE IF EXISTS `DefinitionEntity`');
  await database.execute('DROP TABLE IF EXISTS `WordEntity`');
  await database.execute('DROP TABLE IF EXISTS `PackageEntity`');

  await database.execute(
    'CREATE TABLE IF NOT EXISTS `PackageEntity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `author` TEXT NOT NULL, `category` TEXT NOT NULL, `description` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `language` TEXT NOT NULL, `lastUpdatedDate` TEXT NOT NULL, `level` TEXT NOT NULL, `title` TEXT NOT NULL, `version` INTEGER NOT NULL)',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `WordEntity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `packageId` INTEGER NOT NULL, `text` TEXT NOT NULL)',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `DefinitionEntity` (`id` INTEGER, `wordId` INTEGER NOT NULL, `text` TEXT NOT NULL, `source` TEXT NOT NULL, PRIMARY KEY (`id`))',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `SentenceEntity` (`id` INTEGER, `wordId` INTEGER NOT NULL, `text` TEXT NOT NULL, PRIMARY KEY (`id`))',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS `ResourceEntity` (`id` INTEGER, `sentenceId` INTEGER NOT NULL, `title` TEXT NOT NULL, `url` TEXT NOT NULL, `type` TEXT NOT NULL, PRIMARY KEY (`id`))',
  );
});

final openCallback = Callback(
  onOpen: (database) async {
    await database.execute('PRAGMA foreign_keys = ON');
  },
);

Future<AppDatabase> openAndSeedDatabase() async {
  if (_appDatabase != null) return _appDatabase!;

  final db = await $FloorAppDatabase
      .databaseBuilder('kalimaiti_app.db')
      .addMigrations([_migration1to2])
      .addCallback(openCallback)
      .build();
  await DatabaseSeederService.seedDatabaseWith(db);
  _appDatabase = db;
  return _appDatabase!;
}

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  return _appDatabase ??= await openAndSeedDatabase();
});
