# How to View Your Floor SQLite Database

Similar to Prisma Studio, here are several ways to visualize and interact with your SQLite database:

## Option 1: DB Browser for SQLite (Recommended - Most Similar to Prisma Studio)

**DB Browser for SQLite** is a free, open-source visual tool for SQLite databases.

### Install on macOS:

```bash
brew install --cask db-browser-for-sqlite
```

### Usage:

1. Open DB Browser for SQLite
2. Click "Open Database"
3. Navigate to your database file: `kalimaiti_app.db`
4. Browse tables, edit data, run SQL queries in a visual interface

**Features:**

- Visual table browser (like Prisma Studio)
- Edit data directly in tables
- SQL query editor with syntax highlighting
- Export to CSV, SQL, JSON
- Database structure visualization

## Option 2: TablePlus (Premium but has free tier)

**TablePlus** is a modern database GUI that supports SQLite and many other databases.

### Install on macOS:

```bash
brew install --cask tableplus
```

### Usage:

1. Open TablePlus
2. Click "Create a new connection"
3. Select "SQLite"
4. Choose your `kalimaiti_app.db` file
5. Browse tables with a beautiful UI

**Features:**

- Modern, clean UI (very similar to Prisma Studio)
- Multi-tab interface
- Inline editing
- SQL query editor
- Code review before executing changes

## Option 3: SQLite CLI (Built-in, No Installation)

macOS comes with SQLite CLI pre-installed.

### Usage:

```bash
# Open the database
sqlite3 kalimaiti_app.db

# Inside SQLite prompt, useful commands:
.tables                           # List all tables
.schema UserEntity                # Show table structure
SELECT * FROM UserEntity;         # Query data
.mode column                      # Format output in columns
.headers on                       # Show column headers
.exit                            # Exit SQLite
```

### Quick view script:

```bash
# View all tables and their row counts
sqlite3 kalimaiti_app.db "SELECT name FROM sqlite_master WHERE type='table';" | \
  while read table; do
    count=$(sqlite3 kalimaiti_app.db "SELECT COUNT(*) FROM $table;")
    echo "$table: $count rows"
  done
```

## Option 4: VS Code Extension - SQLite Viewer

Install the **SQLite Viewer** extension in VS Code.

### Install:

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "SQLite Viewer" by alexcvzz
4. Install it

### Usage:

1. Open your `kalimaiti_app.db` file in VS Code
2. Click "Open anyway" if prompted
3. Right-click the file → "Open Database"
4. Browse tables in the sidebar
5. Click tables to view data in a spreadsheet-like interface

## Option 5: Custom Dart CLI Viewer (Included in this project)

I'll create a custom viewer script that lets you browse your database from the terminal.

```bash
# View all data
dart run tools/view_db.dart

# View specific table
dart run tools/view_db.dart --table UserEntity

# Export to JSON
dart run tools/view_db.dart --export users.json
```

## First Time Setup

Before viewing the database, you must:

1. **Generate Floor code:**

   ```bash
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Seed the database:**

   ```bash
   dart run tools/seed_floor_db.dart
   ```

3. **Verify database created:**
   ```bash
   ls -la kalimaiti_app.db
   ```

## Recommended Workflow

For the best experience (most similar to Prisma Studio):

1. **Development:** Use **DB Browser for SQLite** or **TablePlus** for visual browsing
2. **Quick checks:** Use SQLite CLI for fast queries
3. **VS Code users:** Use SQLite Viewer extension for in-editor viewing

## Database Location

By default, the seeder creates `kalimaiti_app.db` in the project root directory.

If you want to change the location:

- Edit `tools/seed_floor_db.dart`
- Change the database builder path from `'kalimaiti_app.db'` to your preferred location
- For example: `'assets/database/kalimaiti_app.db'` to keep it in assets

## Example Queries

Once you have the database open in any tool:

```sql
-- View all users
SELECT * FROM UserEntity;

-- View all packages with their details
SELECT packageRemoteId, title, category, level FROM PackageEntity;

-- Count words per package
SELECT p.title, COUNT(w.id) as word_count
FROM PackageEntity p
LEFT JOIN WordEntity w ON p.packageRemoteId = w.packageRemoteId
GROUP BY p.packageRemoteId;

-- Find all definitions for a specific word
SELECT w.text, d.text as definition, d.source
FROM WordEntity w
JOIN DefinitionEntity d ON w.id = d.wordId
WHERE w.text = 'Apple';

-- View resources by type
SELECT type, COUNT(*) as count
FROM ResourceEntity
GROUP BY type;
```
