import 'dart:convert';
import 'dart:io';

import 'package:kalimaiti_app/core/data/floor/app_database.dart';
import 'package:kalimaiti_app/core/data/floor/user_entity.dart';
import 'package:kalimaiti_app/core/data/floor/package_entity.dart';
import 'package:kalimaiti_app/core/data/floor/word_entity.dart';
import 'package:kalimaiti_app/core/data/floor/definition_entity.dart';
import 'package:kalimaiti_app/core/data/floor/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/floor/resource_entity.dart';

/// Seeder for Floor DB. Run after generating Floor code with build_runner.
Future<void> main(List<String> args) async {
  final repoRoot = Directory.current.path;
  final usersPath = args.isNotEmpty ? args[0] : '$repoRoot/users.json';
  final packagesPath = args.length > 1
      ? args[1]
      : '$repoRoot/lib/assets/packages.json';

  final usersFile = File(usersPath);
  final packagesFile = File(packagesPath);

  if (!await usersFile.exists()) {
    stderr.writeln('users.json not found at $usersPath');
    exit(2);
  }
  if (!await packagesFile.exists()) {
    stderr.writeln('packages.json not found at $packagesPath');
    exit(2);
  }

  // IMPORTANT: generated code must exist (run build_runner) to use $FloorAppDatabase
  final database = await $FloorAppDatabase
      .databaseBuilder('kalimaiti_app.db')
      .build();

  final usersJson = jsonDecode(await usersFile.readAsString()) as List<dynamic>;
  final packagesJson =
      jsonDecode(await packagesFile.readAsString()) as List<dynamic>;

  // Insert users
  final userEntities = usersJson
      .map(
        (u) => UserEntity(
          firstName: u['firstName'] ?? '',
          lastName: u['lastName'] ?? '',
          email: u['email'] ?? '',
          password: u['password'] ?? '',
          photoUrl: u['photoUrl'] ?? '',
          role: u['role'] ?? '',
        ),
      )
      .toList();

  if (userEntities.isNotEmpty) {
    await database.userDao.insertUsers(userEntities);
    print('Inserted ${userEntities.length} users');
  }

  // Insert packages and nested data
  for (final p in packagesJson) {
    final packageRemoteId = p['packageId'] ?? '';
    final pkg = PackageEntity(
      packageRemoteId: packageRemoteId,
      author: p['author'] ?? '',
      category: p['category'] ?? '',
      description: p['description'] ?? '',
      iconUrl: p['iconUrl'] ?? '',
      language: p['language'] ?? '',
      lastUpdatedDate: p['lastUpdatedDate'] ?? '',
      level: p['level'] ?? '',
      title: p['title'] ?? '',
      version: (p['version'] is int)
          ? p['version'] as int
          : int.tryParse('${p['version']}') ?? 0,
    );

    await database.packageDao.insertPackage(pkg);

    final words = (p['words'] as List<dynamic>?) ?? [];
    for (final w in words) {
      final wordEntity = WordEntity(
        packageRemoteId: packageRemoteId,
        text: w['text'] ?? '',
      );
      final wordId = await database.wordDao.insertWord(wordEntity);

      // definitions
      final defs = (w['definitions'] as List<dynamic>?) ?? [];
      for (final d in defs) {
        final defEnt = DefinitionEntity(
          wordId: wordId,
          text: d['text'] ?? '',
          source: d['source'] ?? '',
        );
        await database.definitionDao.insertDefinition(defEnt);
      }

      // sentences and their resources
      final sents = (w['sentences'] as List<dynamic>?) ?? [];
      for (final s in sents) {
        final sentEnt = SentenceEntity(wordId: wordId, text: s['text'] ?? '');
        final sentId = await database.sentenceDao.insertSentence(sentEnt);

        final resources = (s['resources'] as List<dynamic>?) ?? [];
        for (final r in resources) {
          final resEnt = ResourceEntity(
            sentenceId: sentId,
            title: r['title'] ?? '',
            url: r['url'] ?? '',
            type: r['type'] ?? '',
          );
          await database.resourceDao.insertResource(resEnt);
        }
      }
    }
  }

  print(
    'Seeding complete. DB located at the current working dir: kalimaiti_app.db',
  );
  await database.close();
}
