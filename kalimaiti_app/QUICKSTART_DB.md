# 🎯 Quick Start: View Your Floor Database

## TL;DR - Get Started in 1 Command

```bash
./scripts/setup_db.sh
```

This script will:

1. ✅ Install dependencies
2. ✅ Generate Floor code
3. ✅ Seed the database
4. ✅ Show you how to view it

---

## Option 1: DB Browser for SQLite (Recommended - Like Prisma Studio)

**Best visual experience, closest to Prisma Studio**

```bash
# Install (one-time)
brew install --cask db-browser-for-sqlite

# Open your database
open -a "DB Browser for SQLite" kalimaiti_app.db
```

**Features:**

- ✨ Beautiful visual interface
- 📊 Browse tables like spreadsheets
- ✏️ Edit data directly
- 🔍 SQL query editor
- 📤 Export to JSON/CSV/SQL

---

## Option 2: TablePlus (Modern Premium Tool)

**Sleek, modern UI - also very similar to Prisma Studio**

```bash
# Install (one-time)
brew install --cask tableplus

# Open TablePlus and connect to your .db file
```

---

## Option 3: Custom Dart Viewer (Included)

**Interactive terminal viewer - no external tools needed**

```bash
# Interactive menu
dart run tools/view_db.dart

# Show statistics
dart run tools/view_db.dart --stats

# View specific table
dart run tools/view_db.dart --table users

# Export to JSON
dart run tools/view_db.dart --export backup.json
```

---

## Option 4: SQLite CLI (Built-in)

**Quick command-line queries**

```bash
# Open database
sqlite3 kalimaiti_app.db

# Run queries
sqlite> .tables                    # List tables
sqlite> .schema UserEntity         # Show structure
sqlite> SELECT * FROM UserEntity;  # View data
sqlite> .exit                      # Exit
```

**One-liner queries:**

```bash
# Count users
sqlite3 kalimaiti_app.db "SELECT COUNT(*) FROM UserEntity;"

# View all packages
sqlite3 kalimaiti_app.db "SELECT packageRemoteId, title, category FROM PackageEntity;"

# Count words per package
sqlite3 kalimaiti_app.db "SELECT packageRemoteId, COUNT(*) FROM WordEntity GROUP BY packageRemoteId;"
```

---

## Option 5: VS Code Extension

**View database without leaving VS Code**

1. Install "SQLite Viewer" extension by alexcvzz
2. Open `kalimaiti_app.db` in VS Code
3. Right-click → "Open Database"
4. Browse tables in sidebar

---

## Troubleshooting

### Database not found?

```bash
# Make sure you ran the setup
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
dart run tools/seed_floor_db.dart

# Check if database exists
ls -la kalimaiti_app.db
```

### Build runner errors?

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Need to reset database?

```bash
# Delete and recreate
rm kalimaiti_app.db
dart run tools/seed_floor_db.dart
```

---

## Useful Queries

```sql
-- View all users
SELECT * FROM UserEntity;

-- Packages by category
SELECT category, COUNT(*) FROM PackageEntity GROUP BY category;

-- Words with their package
SELECT w.text, p.title
FROM WordEntity w
JOIN PackageEntity p ON w.packageRemoteId = p.packageRemoteId;

-- Find specific word definitions
SELECT w.text, d.text as definition
FROM WordEntity w
JOIN DefinitionEntity d ON w.id = d.wordId
WHERE w.text LIKE '%Apple%';
```

---

## Next Steps

Once your database is set up:

1. **Use it in your Flutter app** - The Floor database is ready to use
2. **Add more data** - Edit the JSON files and re-run the seeder
3. **Create custom queries** - Add new DAO methods in `lib/core/data/floor/daos.dart`

For full documentation, see: `scripts/VIEW_DATABASE.md`
