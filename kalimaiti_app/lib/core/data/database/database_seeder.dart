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
    final existingPackages = await database.packageDao.findAllPackages();
    final existingWords = await database.wordDao.findAllWords();

    final needsUsers = existingUsers.isEmpty;
    final needsPackages = existingPackages.isEmpty;

    if (!needsUsers && !needsPackages) {
      print('📊 Database already contains data, skipping seed...');
      print('   Found ${existingUsers.length} users in database');
      print('   📦 ${existingPackages.length} packages');
      print('   📝 ${existingWords.length} words');
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

      if (needsUsers) {
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
      } else {
        print('👥 Users already present, skipping user seeding.');
      }

      if (needsPackages) {
        // Seed packages and related data
        print('📦 Seeding packages...');
        int totalWords = 0;
        int totalDefinitions = 0;
        int totalSentences = 0;
        int totalResources = 0;

        for (var packageData in packagesList) {
          final packageMap = Map<String, dynamic>.from(
            packageData as Map<String, dynamic>,
          );
          _validatePackageStructure(packageMap);
          // Insert package
          final package = PackageEntity(
            author: packageMap['author'],
            category: packageMap['category'],
            description: packageMap['description'],
            iconUrl: packageMap['iconUrl'],
            language: packageMap['language'],
            lastUpdatedDate: packageMap['lastUpdatedDate'],
            level: packageMap['level'],
            title: packageMap['title'],
            version: packageMap['version'],
          );
          final packageId = await database.packageDao.insertPackage(package);

          // Insert words
          final words = (packageMap['words'] as List<dynamic>?) ?? [];
          for (var wordData in words) {
            final word = WordEntity(
              packageId: packageId,
              text: wordData['text'],
            );
            final wordId = await database.wordDao.insertWord(word);
            totalWords++;

            // Insert definitions
            final definitions =
                (wordData['definitions'] as List<dynamic>?) ?? [];
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
              final resources =
                  (sentData['resources'] as List<dynamic>?) ?? [];
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
      } else {
        print('📦 Packages already present, skipping package seeding.');
      }

      print('🎉 Database seeding completed successfully!');

      return true;
    } catch (e) {
      print('❌ Error seeding database: $e');
      rethrow;
    }
  }

  static void _validatePackageStructure(Map<String, dynamic> packageData) {
    final words = packageData['words'];
    if (words is! List || words.isEmpty) {
      throw FormatException(
        'Package "${packageData['title']}" must include at least one word.',
      );
    }

    for (final rawWord in words) {
      if (rawWord is! Map<String, dynamic>) {
        throw const FormatException('Word entries must be JSON objects.');
      }

      final wordText = rawWord['text'] as String? ?? '';
      if (wordText.trim().isEmpty) {
        throw FormatException(
          'A word entry in package "${packageData['title']}" is missing "text".',
        );
      }

      final definitions = rawWord['definitions'];
      if (definitions is! List || definitions.isEmpty) {
        throw FormatException(
          'Word "$wordText" in package "${packageData['title']}" must have at least one definition.',
        );
      }

      for (final def in definitions) {
        if (def is! Map<String, dynamic>) {
          throw FormatException(
            'Definitions for word "$wordText" must be JSON objects.',
          );
        }
        final text = def['text'] as String? ?? '';
        final source = def['source'] as String? ?? '';
        if (text.trim().isEmpty || source.trim().isEmpty) {
          throw FormatException(
            'Definition entries for word "$wordText" in package "${packageData['title']}" require both "text" and "source".',
          );
        }
      }

      final sentences = rawWord['sentences'];
      if (sentences is! List || sentences.isEmpty) {
        throw FormatException(
          'Word "$wordText" in package "${packageData['title']}" must include at least one sentence.',
        );
      }

      for (final sentence in sentences) {
        if (sentence is! Map<String, dynamic>) {
          throw FormatException(
            'Sentences for word "$wordText" must be JSON objects.',
          );
        }
        final sentenceText = sentence['text'] as String? ?? '';
        if (sentenceText.trim().isEmpty) {
          throw FormatException(
            'Sentence entries for word "$wordText" in package "${packageData['title']}" require "text".',
          );
        }

        final resources = sentence['resources'];
        if (resources is! List || resources.isEmpty) {
          throw FormatException(
            'Sentence "$sentenceText" for word "$wordText" in package "${packageData['title']}" must include at least one resource.',
          );
        }

        for (final resource in resources) {
          if (resource is! Map<String, dynamic>) {
            throw FormatException(
              'Resources for sentence "$sentenceText" must be JSON objects.',
            );
          }
          final title = resource['title'] as String? ?? '';
          final url = resource['url'] as String? ?? '';
          final type = resource['type'] as String? ?? '';
          if (title.trim().isEmpty || url.trim().isEmpty || type.trim().isEmpty) {
            throw FormatException(
              'Resources for sentence "$sentenceText" in word "$wordText" must include "title", "url", and "type".',
            );
          }
        }
      }
    }
  }
}
