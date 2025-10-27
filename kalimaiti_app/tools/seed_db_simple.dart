import 'dart:convert';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as path;

/// Simple database seeder that works on desktop using FFI
void main() async {
  // Initialize FFI for desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  print('🌱 Starting database seeding...\n');

  // Get project root
  final projectRoot = Directory.current.path;
  final dbPath = path.join(projectRoot, 'kalimaiti_app.db');

  // Delete existing database if it exists
  if (await File(dbPath).exists()) {
    print('🗑️  Deleting existing database...');
    await File(dbPath).delete();
  }

  // Create database
  print('📦 Creating database at: $dbPath');
  final database = await databaseFactory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        print('🔨 Creating tables...');

        // Create UserEntity table
        await db.execute('''
          CREATE TABLE UserEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            email TEXT NOT NULL,
            password TEXT NOT NULL,
            photoUrl TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // Create PackageEntity table
        await db.execute('''
          CREATE TABLE PackageEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            packageRemoteId INTEGER NOT NULL,
            packageName TEXT NOT NULL,
            packageDescription TEXT NOT NULL,
            packagePhotoUrl TEXT NOT NULL
          )
        ''');

        // Create WordEntity table
        await db.execute('''
          CREATE TABLE WordEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            packageId INTEGER NOT NULL,
            wordRemoteId INTEGER NOT NULL,
            wordTitle TEXT NOT NULL,
            wordPronunciation TEXT NOT NULL,
            wordPrimaryAudio TEXT NOT NULL,
            wordSecondaryAudio TEXT NOT NULL,
            FOREIGN KEY (packageId) REFERENCES PackageEntity(id)
          )
        ''');

        // Create DefinitionEntity table
        await db.execute('''
          CREATE TABLE DefinitionEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wordId INTEGER NOT NULL,
            definitionRemoteId INTEGER NOT NULL,
            definitionText TEXT NOT NULL,
            definitionExplanation TEXT NOT NULL,
            FOREIGN KEY (wordId) REFERENCES WordEntity(id)
          )
        ''');

        // Create SentenceEntity table
        await db.execute('''
          CREATE TABLE SentenceEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wordId INTEGER NOT NULL,
            sentenceRemoteId INTEGER NOT NULL,
            sentenceText TEXT NOT NULL,
            sentenceAudio TEXT NOT NULL,
            FOREIGN KEY (wordId) REFERENCES WordEntity(id)
          )
        ''');

        // Create ResourceEntity table
        await db.execute('''
          CREATE TABLE ResourceEntity (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            wordId INTEGER NOT NULL,
            resourceRemoteId INTEGER NOT NULL,
            resourceTitle TEXT NOT NULL,
            resourceUrl TEXT NOT NULL,
            resourceType TEXT NOT NULL,
            FOREIGN KEY (wordId) REFERENCES WordEntity(id)
          )
        ''');

        print('✅ Tables created successfully\n');
      },
    ),
  );

  // Read and insert users
  print('👥 Inserting users...');
  final usersFile = File(path.join(projectRoot, 'users.json'));
  if (!await usersFile.exists()) {
    print('❌ Error: users.json not found');
    exit(1);
  }

  final usersJson = jsonDecode(await usersFile.readAsString()) as List;
  print('   Found ${usersJson.length} users');

  for (final user in usersJson) {
    await database.insert('UserEntity', {
      'firstName': user['firstName'] ?? '',
      'lastName': user['lastName'] ?? '',
      'email': user['email'] ?? '',
      'password': user['password'] ?? '',
      'photoUrl': user['photoUrl'] ?? '',
      'role': user['role'] ?? '',
    });
  }
  print('✅ Inserted ${usersJson.length} users\n');

  // Read and insert packages with nested data
  print(
    '📚 Inserting packages, words, definitions, sentences, and resources...',
  );
  final packagesFile = File(path.join(projectRoot, 'packages.json'));
  if (!await packagesFile.exists()) {
    print('❌ Error: packages.json not found');
    exit(1);
  }

  final packages = jsonDecode(await packagesFile.readAsString()) as List;
  print('   Found ${packages.length} packages');

  int totalWords = 0;
  int totalDefinitions = 0;
  int totalSentences = 0;
  int totalResources = 0;

  for (final package in packages) {
    // Insert package
    final packageId = await database.insert('PackageEntity', {
      'packageRemoteId': (package['packageId'] as String).hashCode,
      'packageName': package['title'] ?? '',
      'packageDescription': package['description'] ?? '',
      'packagePhotoUrl': package['iconUrl'] ?? '',
    });

    // Insert words
    final words = package['words'] as List? ?? [];
    for (final word in words) {
      final wordId = await database.insert('WordEntity', {
        'packageId': packageId,
        'wordRemoteId': (word['text'] as String).hashCode,
        'wordTitle': word['text'] ?? '',
        'wordPronunciation': word['pronunciation'] ?? '',
        'wordPrimaryAudio': word['primaryAudio'] ?? '',
        'wordSecondaryAudio': word['secondaryAudio'] ?? '',
      });
      totalWords++;

      // Insert definitions
      final definitions = word['definitions'] as List? ?? [];
      for (final definition in definitions) {
        await database.insert('DefinitionEntity', {
          'wordId': wordId,
          'definitionRemoteId': (definition['text'] as String).hashCode,
          'definitionText': definition['text'] ?? '',
          'definitionExplanation': definition['source'] ?? '',
        });
        totalDefinitions++;
      }

      // Insert sentences
      final sentences = word['sentences'] as List? ?? [];
      for (final sentence in sentences) {
        await database.insert('SentenceEntity', {
          'wordId': wordId,
          'sentenceRemoteId': (sentence['text'] as String).hashCode,
          'sentenceText': sentence['text'] ?? '',
          'sentenceAudio': '',
        });
        totalSentences++;

        // Insert resources (nested under sentences)
        final resources = sentence['resources'] as List? ?? [];
        for (final resource in resources) {
          await database.insert('ResourceEntity', {
            'wordId': wordId,
            'resourceRemoteId': (resource['url'] as String).hashCode,
            'resourceTitle': resource['title'] ?? '',
            'resourceUrl': resource['url'] ?? '',
            'resourceType': resource['type'] ?? '',
          });
          totalResources++;
        }
      }
    }
  }
  print('✅ Inserted ${packages.length} packages');
  print('✅ Inserted $totalWords words');
  print('✅ Inserted $totalDefinitions definitions');
  print('✅ Inserted $totalSentences sentences');
  print('✅ Inserted $totalResources resources\n');

  await database.close();

  print('🎉 Database seeding completed successfully!');
  print('📍 Database location: $dbPath');
  print('\n💡 You can now view the database with:');
  print('   - DB Browser for SQLite');
  print('   - sqlite3 kalimaiti_app.db');
}
