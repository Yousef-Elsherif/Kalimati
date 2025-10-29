import 'dart:convert';
import 'package:flutter/services.dart';
import 'app_database.dart';
import 'entities/user_entity.dart';
import 'entities/package_entity.dart';
import 'entities/word_entity.dart';
import 'entities/definition_entity.dart';
import 'entities/sentence_entity.dart';
import 'entities/resource_entity.dart';

/// Service to seed the database from JSON files in assets/data
class DatabaseSeederService {
  /// Seeder utilities. Prefer using `seedDatabaseWith(AppDatabase)` so callers
  /// (such as the database provider) can seed the already-open database instance
  /// and avoid creating an extra DB connection.

  /// Seed using an existing [AppDatabase] instance. This lets callers (e.g. the provider)
  /// build/open the DB and then run seeding without double-building.
  static Future<bool> seedDatabaseWith(AppDatabase database) async {
    // Check if already seeded
    final existingUsers = await database.userDao.findAllUsers();
    if (existingUsers.isNotEmpty) {
      print('📊 Database already contains data, skipping seed...');
      print('   Found ${existingUsers.length} users in database');

      // Show current counts
      final packages = await database.packageDao.findAllPackages();
      final words = await database.wordDao.findAllWords();
      print('   📦 ${packages.length} packages');
      print('   📝 ${words.length} words');

      return false;
    }

    print('🌱 Starting database seeding from assets/data...');

    try {
      // Load JSON files
      final usersJson = await rootBundle.loadString('assets/data/users.json');
      final packagesJson = await rootBundle.loadString(
        'assets/data/packages.json',
      );

      final usersList = json.decode(usersJson) as List<dynamic>;
      final packagesList = json.decode(packagesJson) as List<dynamic>;

      // Seed users
      print('👥 Seeding users...');
      for (var userData in usersList) {
        final user = UserEntity(
          firstName: userData['firstName'],
          lastName: userData['lastName'],
          email: userData['email'],
          password: userData['password'],
          photoUrl: userData['photoUrl'],
          role: userData['role'],
        );
        await database.userDao.insertUser(user);
      }
      print('✅ Seeded ${usersList.length} users');

      // Seed packages and related data
      print('📦 Seeding packages...');
      int totalWords = 0;
      int totalDefinitions = 0;
      int totalSentences = 0;
      int totalResources = 0;

      for (var packageData in packagesList) {
        // Insert package
        final package = PackageEntity(
          packageRemoteId: packageData['packageId'],
          author: packageData['author'],
          category: packageData['category'],
          description: packageData['description'],
          iconUrl: packageData['iconUrl'],
          language: packageData['language'],
          lastUpdatedDate: packageData['lastUpdatedDate'],
          level: packageData['level'],
          title: packageData['title'],
          version: packageData['version'],
        );
        await database.packageDao.insertPackage(package);

        // Insert words
        final words = (packageData['words'] as List<dynamic>?) ?? [];
        for (var wordData in words) {
          final word = WordEntity(
            packageRemoteId: packageData['packageId'],
            text: wordData['text'],
          );
          final wordId = await database.wordDao.insertWord(word);
          totalWords++;

          // Insert definitions
          final definitions = (wordData['definitions'] as List<dynamic>?) ?? [];
          for (var defData in definitions) {
            final definition = DefinitionEntity(
              wordId: wordId,
              text: defData['text'],
              source: defData['source'],
            );
            await database.definitionDao.insertDefinition(definition);
            totalDefinitions++;
          }

          // Insert sentences
          final sentences = (wordData['sentences'] as List<dynamic>?) ?? [];
          for (var sentData in sentences) {
            final sentence = SentenceEntity(
              wordId: wordId,
              text: sentData['text'],
            );
            final sentId = await database.sentenceDao.insertSentence(sentence);
            totalSentences++;

            // Insert resources for sentence
            final resources = (sentData['resources'] as List<dynamic>?) ?? [];
            for (var resData in resources) {
              final resource = ResourceEntity(
                sentenceId: sentId,
                title: resData['title'],
                url: resData['url'],
                type: resData['type'],
              );
              await database.resourceDao.insertResource(resource);
              totalResources++;
            }
          }
        }
      }

      print('✅ Seeded ${packagesList.length} packages');
      print('✅ Seeded $totalWords words');
      print('✅ Seeded $totalDefinitions definitions');
      print('✅ Seeded $totalSentences sentences');
      print('✅ Seeded $totalResources resources');
      print('🎉 Database seeding completed successfully!');

      return true;
    } catch (e) {
      print('❌ Error seeding database: $e');
      rethrow;
    }
  }
}
