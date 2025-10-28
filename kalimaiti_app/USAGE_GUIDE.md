# Kalimati Learning App - Usage Guide

## Quick Start

### 1. First Time Setup

```bash
# Install dependencies
flutter pub get

# Generate Floor database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app (database will be automatically seeded on first run)
flutter run
```

**Note**: The app automatically seeds the database from `assets/data/*.json` on first run. The seeding only happens once - if data already exists, it will skip seeding.

### 2. Development Workflow

```bash
# When you modify entities or DAOs, regenerate Floor code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Project Structure Overview

```
lib/
├── core/
│   └── data/
│       ├── database/          # Floor SQLite Database
│       │   ├── app_database.dart
│       │   ├── app_database.g.dart (generated)
│       │   ├── entities/      # Database entities (6 files)
│       │   ├── dao/           # Data Access Objects (6 files)
│       │   └── helpers/       # Database helper singleton
│       └── repositories/      # Repository pattern layer
│           ├── user_repository.dart
│           ├── package_repository.dart
│           └── word_repository.dart
└── features/                  # Feature-based modules
    ├── home/
    ├── packages/
    │   └── screens/
    │       └── packages_screen.dart (example)
    └── words/
```

## How to Use the Database

### Example 1: Using Repositories (Recommended)

```dart
import 'package:kalimaiti_app/core/data/repositories/package_repository.dart';

class PackagesScreen extends StatefulWidget {
  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _packageRepo = PackageRepository();
  List<PackageEntity> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    await _packageRepo.init();
    final packages = await _packageRepo.getAllPackages();
    setState(() {
      _packages = packages;
    });
  }
}
```

### Example 2: Using DAOs Directly

```dart
import 'package:kalimaiti_app/core/data/database/helpers/database_helper.dart';

// Get database instance
final database = await DatabaseHelper.getDatabase();

// Use DAOs
final packages = await database.packageDao.findAllPackages();
final beginnerPackages = await database.packageDao.findByLevel('Beginner');
final words = await database.wordDao.findByPackageId(1);
```

### Example 3: Adding New Data

```dart
// Using repository
final packageRepo = PackageRepository();
await packageRepo.init();

final newPackage = PackageEntity(
  title: 'My New Package',
  description: 'A custom learning package',
  category: 'Custom',
  level: 'Beginner',
  language: 'English',
);

await packageRepo.createPackage(newPackage);
```

## Database Schema

### Entities

1. **UserEntity** - User accounts and authentication
2. **PackageEntity** - Learning packages with metadata
3. **WordEntity** - Words in packages
4. **DefinitionEntity** - Word definitions with sources
5. **SentenceEntity** - Example sentences
6. **ResourceEntity** - Multimedia resources (images, videos, audio)

### Relationships

```
User (id)
Package (id, userId) → references User
Word (id, packageId) → references Package
Definition (id, wordId) → references Word
Sentence (id, wordId) → references Word
Resource (id, definitionId/sentenceId) → references Definition or Sentence
```

## Data Management

### Automatic Database Seeding

The app automatically seeds the database on first run from JSON files located in `assets/data/`:

- **users.json**: Contains 3 sample users (teachers)
- **packages.json**: Contains 4 learning packages with words, definitions, sentences, and multimedia resources

**How it works:**

1. On app startup, `DatabaseSeederService.seedDatabase()` is called
2. It checks if the database already contains users
3. If empty, it loads and imports all data from the JSON files
4. If data exists, it skips seeding to avoid duplicates

**Initial Data:**

- 3 Users (Homer Simpson, Sponge Bob, Bugs Bunny)
- 4 Packages (Places In Town, Places In Town 2, Fruits, Corona)
- Multiple words, definitions, sentences, and multimedia resources

### Manual Seeding

To manually test the seeding process:

```bash
dart run scripts/test_seeding.dart
```

To reset and re-seed the database:

```bash
# Delete the database file
rm kalimaiti_app.db

# Run the app again (will auto-seed)
flutter run
```

## Example Features to Build

### 1. Package List Screen (✅ Done)

- Location: `lib/features/packages/screens/packages_screen.dart`
- Shows all packages with level, category, language
- Uses `PackageRepository`

### 2. Word Detail Screen (TODO)

```dart
// lib/features/words/screens/word_detail_screen.dart
class WordDetailScreen extends StatefulWidget {
  final int wordId;
  // Load word, definitions, sentences, and resources
}
```

### 3. User Profile Screen (TODO)

```dart
// lib/features/profile/screens/profile_screen.dart
class ProfileScreen extends StatefulWidget {
  // Show user info and their packages
  // Uses UserRepository
}
```

### 4. Search Screen (TODO)

```dart
// lib/features/search/screens/search_screen.dart
class SearchScreen extends StatefulWidget {
  // Search words, definitions, sentences
  // Uses WordRepository.searchWords()
}
```

## Tips

1. **Always initialize repositories before use:**

   ```dart
   await _repo.init();
   ```

2. **Close database when app exits:**

   ```dart
   @override
   void dispose() {
     DatabaseHelper.closeDatabase();
     super.dispose();
   }
   ```

3. **Use transactions for bulk operations:**

   ```dart
   final database = await DatabaseHelper.getDatabase();
   await database.database.transaction((txn) async {
     // Multiple insert operations
   });
   ```

4. **Regenerate code after entity changes:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Testing

### Run the Example App

```bash
# Generate Floor database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run on your device/emulator
flutter run
```

The app will start with an empty database. You can add packages through the UI.

## Common Issues

### Issue: Build errors after entity changes

**Solution:** Run build_runner: `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: "Database not found"

**Solution:** The database is created automatically on first run.

## Next Steps

1. ✅ Database structure is ready
2. ✅ Example screen created (packages_screen.dart)
3. 🔲 Build word detail screen
4. 🔲 Add user authentication flow
5. 🔲 Implement search functionality
6. 🔲 Add multimedia playback for resources
7. 🔲 Create package creation form
8. 🔲 Implement JSON import feature

## Documentation

- See `PROJECT_STRUCTURE.md` for detailed architecture
- See Floor documentation: https://floor.codes/

Enjoy building your Kalimati Learning App! 🚀
