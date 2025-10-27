import 'dart:convert';
import 'dart:io';

import 'package:kalimaiti_app/core/data/floor/app_database.dart';

/// Interactive database viewer for Floor DB
/// Usage:
///   dart run tools/view_db.dart                    # Interactive menu
///   dart run tools/view_db.dart --table users      # View users
///   dart run tools/view_db.dart --stats            # Show statistics
///   dart run tools/view_db.dart --export out.json  # Export all data
Future<void> main(List<String> args) async {
  final dbPath = args.contains('--db')
      ? args[args.indexOf('--db') + 1]
      : 'kalimaiti_app.db';

  final dbFile = File(dbPath);
  if (!await dbFile.exists()) {
    stderr.writeln('❌ Database not found: $dbPath');
    stderr.writeln('Run the seeder first: dart run tools/seed_floor_db.dart');
    exit(1);
  }

  final database = await $FloorAppDatabase.databaseBuilder(dbPath).build();

  try {
    if (args.contains('--stats')) {
      await showStats(database);
    } else if (args.contains('--table')) {
      final tableIdx = args.indexOf('--table');
      final tableName = args.length > tableIdx + 1 ? args[tableIdx + 1] : '';
      await showTable(database, tableName);
    } else if (args.contains('--export')) {
      final exportIdx = args.indexOf('--export');
      final outPath = args.length > exportIdx + 1
          ? args[exportIdx + 1]
          : 'export.json';
      await exportData(database, outPath);
    } else {
      await interactiveMenu(database);
    }
  } finally {
    await database.close();
  }
}

Future<void> showStats(AppDatabase db) async {
  print('\n📊 Database Statistics\n${'=' * 50}');

  final users = await db.userDao.findAllUsers();
  final packages = await db.packageDao.findAllPackages();
  final words = await db.wordDao.findAllWords();

  print('Users:    ${users.length}');
  print('Packages: ${packages.length}');
  print('Words:    ${words.length}');

  if (packages.isNotEmpty) {
    print('\n📦 Packages by Category:');
    final categories = <String, int>{};
    for (final p in packages) {
      categories[p.category] = (categories[p.category] ?? 0) + 1;
    }
    categories.forEach((cat, count) {
      print('  $cat: $count');
    });
  }

  if (users.isNotEmpty) {
    print('\n👥 Users by Role:');
    final roles = <String, int>{};
    for (final u in users) {
      roles[u.role] = (roles[u.role] ?? 0) + 1;
    }
    roles.forEach((role, count) {
      print('  $role: $count');
    });
  }
}

Future<void> showTable(AppDatabase db, String tableName) async {
  print('\n📋 Table: $tableName\n${'=' * 80}');

  switch (tableName.toLowerCase()) {
    case 'users':
    case 'userentity':
      final users = await db.userDao.findAllUsers();
      if (users.isEmpty) {
        print('No users found');
        return;
      }
      print(
        '${'ID'.padRight(5)} ${'First Name'.padRight(15)} ${'Last Name'.padRight(15)} ${'Email'.padRight(25)} ${'Role'.padRight(10)}',
      );
      print('-' * 80);
      for (final u in users) {
        print(
          '${(u.id?.toString() ?? '-').padRight(5)} ${u.firstName.padRight(15)} ${u.lastName.padRight(15)} ${u.email.padRight(25)} ${u.role.padRight(10)}',
        );
      }
      break;

    case 'packages':
    case 'packageentity':
      final packages = await db.packageDao.findAllPackages();
      if (packages.isEmpty) {
        print('No packages found');
        return;
      }
      print(
        '${'ID'.padRight(5)} ${'Package ID'.padRight(12)} ${'Title'.padRight(25)} ${'Category'.padRight(20)} ${'Level'.padRight(12)}',
      );
      print('-' * 80);
      for (final p in packages) {
        print(
          '${(p.id?.toString() ?? '-').padRight(5)} ${p.packageRemoteId.padRight(12)} ${p.title.padRight(25)} ${p.category.padRight(20)} ${p.level.padRight(12)}',
        );
      }
      break;

    case 'words':
    case 'wordentity':
      final words = await db.wordDao.findAllWords();
      if (words.isEmpty) {
        print('No words found');
        return;
      }
      print(
        '${'ID'.padRight(5)} ${'Package ID'.padRight(12)} ${'Word'.padRight(30)}',
      );
      print('-' * 50);
      for (final w in words) {
        print(
          '${(w.id?.toString() ?? '-').padRight(5)} ${w.packageRemoteId.padRight(12)} ${w.text.padRight(30)}',
        );
      }
      break;

    default:
      print('Unknown table: $tableName');
      print('Available tables: users, packages, words');
  }
}

Future<void> exportData(AppDatabase db, String outPath) async {
  print('📤 Exporting database to $outPath...');

  final users = await db.userDao.findAllUsers();
  final packages = await db.packageDao.findAllPackages();
  final words = await db.wordDao.findAllWords();

  final export = {
    'users': users
        .map(
          (u) => {
            'id': u.id,
            'firstName': u.firstName,
            'lastName': u.lastName,
            'email': u.email,
            'role': u.role,
            'photoUrl': u.photoUrl,
          },
        )
        .toList(),
    'packages': packages
        .map(
          (p) => {
            'id': p.id,
            'packageRemoteId': p.packageRemoteId,
            'title': p.title,
            'category': p.category,
            'description': p.description,
            'level': p.level,
            'author': p.author,
            'version': p.version,
          },
        )
        .toList(),
    'words': words
        .map(
          (w) => {
            'id': w.id,
            'packageRemoteId': w.packageRemoteId,
            'text': w.text,
          },
        )
        .toList(),
  };

  final file = File(outPath);
  await file.writeAsString(JsonEncoder.withIndent('  ').convert(export));
  print('✅ Exported successfully!');
  print('   Users: ${users.length}');
  print('   Packages: ${packages.length}');
  print('   Words: ${words.length}');
}

Future<void> interactiveMenu(AppDatabase db) async {
  while (true) {
    print('\n🗄️  Database Viewer (Floor)\n${'=' * 50}');
    print('1. Show statistics');
    print('2. View users');
    print('3. View packages');
    print('4. View words');
    print('5. Export to JSON');
    print('0. Exit');
    print('');
    stdout.write('Choose an option: ');

    final input = stdin.readLineSync()?.trim() ?? '';

    switch (input) {
      case '1':
        await showStats(db);
        break;
      case '2':
        await showTable(db, 'users');
        break;
      case '3':
        await showTable(db, 'packages');
        break;
      case '4':
        await showTable(db, 'words');
        break;
      case '5':
        stdout.write('Export filename [export.json]: ');
        final filename = stdin.readLineSync()?.trim();
        await exportData(
          db,
          filename?.isEmpty == true ? 'export.json' : filename!,
        );
        break;
      case '0':
        print('Goodbye! 👋');
        return;
      default:
        print('❌ Invalid option. Try again.');
    }
  }
}
