# DB generator

This project includes a small generator script that aggregates the project's JSON files into a single JSON database file at `lib/assets/data/db.json`.

Files:

- `tools/generate_db.dart` — Dart script that reads `users.json` (project root) and `lib/assets/packages.json` and writes `lib/assets/data/db.json`.
- `lib/assets/data/db.json` — Example aggregated database (created from current files).

How to run

From the repository root run:

```bash
# run with default paths (reads `users.json` at project root and packages at `lib/assets/packages.json`)
dart run tools/generate_db.dart

# or pass explicit paths
dart run tools/generate_db.dart /absolute/path/to/users.json /absolute/path/to/lib/assets/packages.json /absolute/path/to/output/db.json
```

Notes

- The generator is pure Dart and doesn't add dependencies. It's safe to run locally to refresh `lib/assets/data/db.json` if you edit source JSON files.

Using Floor (SQLite) instead

This repo now includes a Floor (SQLite) schema + a seeder script that will import `users.json` and `lib/assets/packages.json` into a local SQLite database using Floor.

Steps:

1. Add packages and run pub get (we updated `pubspec.yaml` already):

```bash
flutter pub get
```

2. Generate Floor code (this will create the generated `app_database.g.dart` file):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the seeder script (it expects to be run from the repository root):

```bash
dart run tools/seed_floor_db.dart
```

You can pass explicit paths to `users.json` or `packages.json` as arguments if needed.

If you want the generated DB file to be available inside the Flutter app, move the created `kalimaiti_app.db` file into `assets/` and add it to `pubspec.yaml` under assets, or adapt your app to open the same DB path at runtime.
