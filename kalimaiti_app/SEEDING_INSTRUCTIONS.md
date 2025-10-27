# Database Seeding Instructions

Due to Flutter SDK compatibility issues with standalone scripts, we need to seed the database from within the Flutter app.

## Option 1: Add Seeding to Main App (Recommended)

Add this code to your `lib/main.dart`:

```dart
import 'package:kalimaiti_app/core/data/floor/app_database.dart';
import 'dart:convert';
import 'dart:io';
// Import all entity files...

Future<void> seedDatabase() async {
  final database = await $FloorAppDatabase
      .databaseBuilder('kalimaiti_app.db')
      .build();

  // Load and insert users
  final usersFile = File('assets/users.json');
  final usersJson = jsonDecode(await usersFile.readAsString()) as List;

  for (final u in usersJson) {
    await database.userDao.insertUser(
      UserEntity(
        firstName: u['firstName'] ?? '',
        lastName: u['lastName'] ?? '',
        email: u['email'] ?? '',
        // ... other fields
      ),
    );
  }

  // Similar for packages, words, definitions, etc.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database on first run
  await seedDatabase();

  runApp(MyApp());
}
```

## Option 2: Use DB Browser for SQLite

1. **Install DB Browser for SQLite**:

   ```bash
   brew install --cask db-browser-for-sqlite
   ```

2. **Create and populate database manually**:
   - Open DB Browser
   - Create new database: `kalimaiti_app.db`
   - Execute SQL to create tables (see below)
   - Import JSON data using the "Import" feature

### SQL Schema:

```sql
CREATE TABLE UserEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  email TEXT NOT NULL,
  password TEXT NOT NULL,
  photoUrl TEXT NOT NULL,
  role TEXT NOT NULL
);

CREATE TABLE PackageEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  packageRemoteId INTEGER NOT NULL,
  packageName TEXT NOT NULL,
  packageDescription TEXT NOT NULL,
  packagePhotoUrl TEXT NOT NULL
);

CREATE TABLE WordEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  packageId INTEGER NOT NULL,
  wordRemoteId INTEGER NOT NULL,
  wordTitle TEXT NOT NULL,
  wordPronunciation TEXT NOT NULL,
  wordPrimaryAudio TEXT NOT NULL,
  wordSecondaryAudio TEXT NOT NULL,
  FOREIGN KEY (packageId) REFERENCES PackageEntity(id)
);

CREATE TABLE DefinitionEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wordId INTEGER NOT NULL,
  definitionRemoteId INTEGER NOT NULL,
  definitionText TEXT NOT NULL,
  definitionExplanation TEXT NOT NULL,
  FOREIGN KEY (wordId) REFERENCES WordEntity(id)
);

CREATE TABLE SentenceEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wordId INTEGER NOT NULL,
  sentenceRemoteId INTEGER NOT NULL,
  sentenceText TEXT NOT NULL,
  sentenceAudio TEXT NOT NULL,
  FOREIGN KEY (wordId) REFERENCES WordEntity(id)
);

CREATE TABLE ResourceEntity (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wordId INTEGER NOT NULL,
  resourceRemoteId INTEGER NOT NULL,
  resourceTitle TEXT NOT NULL,
  resourceUrl TEXT NOT NULL,
  resourceType TEXT NOT NULL,
  FOREIGN KEY (wordId) REFERENCES WordEntity(id)
);
```

## Option 3: Use sqflite_common_ffi for Desktop

If you want to run the seeder as a script on desktop:

1. Add dependency to `pubspec.yaml`:

   ```yaml
   dependencies:
     sqflite_common_ffi: ^2.3.0
   ```

2. Update `tools/seed_floor_db.dart` to use FFI:

   ```dart
   import 'package:sqflite_common_ffi/sqflite_ffi.dart';

   void main() async {
     sqfliteFfiInit();
     databaseFactory = databaseFactoryFfi;
     // ... rest of seeding code
   }
   ```

3. Run with:
   ```bash
   dart run tools/seed_floor_db.dart
   ```

## Recommended Approach

For now, **Option 2 (DB Browser)** is the quickest way to get your database set up. You can:

1. Use DB Browser to create the database
2. Import your JSON files manually or write SQL INSERT statements
3. Place the `kalimaiti_app.db` file in your project root
4. Your Flutter app will automatically use it

Later, you can integrate proper seeding into your app's initialization logic (Option 1).
