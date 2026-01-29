import '../../../../core/data/database/app_database.dart';
import '../../../../core/data/database/entities/definition_entity.dart';
import '../../../../core/data/database/entities/package_entity.dart';
import '../../../../core/data/database/entities/resource_entity.dart';
import '../../../../core/data/database/entities/sentence_entity.dart';
import '../../../../core/data/database/entities/word_entity.dart';
import '../../domain/models/learning_package.dart';

/// Maps between the LearningPackage aggregate and database entities
class LearningPackageMapper {
  /// Converts database entities to a LearningPackage aggregate
  static Future<LearningPackage> fromDatabase(
    AppDatabase db,
    PackageEntity packageEntity,
  ) async {
    final packageId = packageEntity.id;
    if (packageId == null) {
      throw Exception('Package entity must have an ID');
    }

    // Fetch all words for this package
    final wordEntities = await db.wordDao.findByPackageId(packageId);
    final words = <Word>[];

    for (final wordEntity in wordEntities) {
      final wordId = wordEntity.id;
      if (wordId == null) continue;

      // Fetch definitions for this word
      final definitionEntities = await db.definitionDao.findForWord(wordId);
      final definitions = definitionEntities
          .map((d) => Definition(id: d.id, text: d.text, source: d.source))
          .toList();

      // Fetch sentences for this word
      final sentenceEntities = await db.sentenceDao.findForWord(wordId);
      final sentences = <Sentence>[];

      for (final sentenceEntity in sentenceEntities) {
        final sentenceId = sentenceEntity.id;
        if (sentenceId == null) continue;

        // Fetch resources for this sentence
        final resourceEntities = await db.resourceDao.findForSentence(
          sentenceId,
        );
        final resources = resourceEntities
            .map(
              (r) =>
                  Resource(id: r.id, title: r.title, url: r.url, type: r.type),
            )
            .toList();

        sentences.add(
          Sentence(
            id: sentenceEntity.id,
            text: sentenceEntity.text,
            resources: resources,
          ),
        );
      }

      words.add(
        Word(
          id: wordEntity.id,
          text: wordEntity.text,
          definitions: definitions,
          sentences: sentences,
        ),
      );
    }

    return LearningPackage(
      id: packageEntity.id,
      author: packageEntity.author,
      category: packageEntity.category,
      description: packageEntity.description,
      iconUrl: packageEntity.iconUrl,
      language: packageEntity.language,
      lastUpdatedDate: packageEntity.lastUpdatedDate,
      level: packageEntity.level,
      title: packageEntity.title,
      version: packageEntity.version,
      words: words,
    );
  }

  /// Converts a LearningPackage aggregate to database entities and persists them
  static Future<int> toDatabase(AppDatabase db, LearningPackage package) async {
    // Insert the package entity
    final packageEntity = PackageEntity(
      id: package.id,
      author: package.author,
      category: package.category,
      description: package.description,
      iconUrl: package.iconUrl,
      language: package.language,
      lastUpdatedDate: package.lastUpdatedDate,
      level: package.level,
      title: package.title,
      version: package.version,
    );

    final packageId = await db.packageDao.insertPackage(packageEntity);

    // Insert all words and their related entities
    for (final word in package.words) {
      final wordEntity = WordEntity(
        id: word.id,
        packageId: packageId,
        text: word.text,
      );
      final wordId = await db.wordDao.insertWord(wordEntity);

      // Insert definitions
      for (final definition in word.definitions) {
        final definitionEntity = DefinitionEntity(
          id: definition.id,
          wordId: wordId,
          text: definition.text,
          source: definition.source,
        );
        await db.definitionDao.insertDefinition(definitionEntity);
      }

      // Insert sentences and their resources
      for (final sentence in word.sentences) {
        final sentenceEntity = SentenceEntity(
          id: sentence.id,
          wordId: wordId,
          text: sentence.text,
        );
        final sentenceId = await db.sentenceDao.insertSentence(sentenceEntity);

        // Insert resources
        for (final resource in sentence.resources) {
          final resourceEntity = ResourceEntity(
            id: resource.id,
            sentenceId: sentenceId,
            title: resource.title,
            url: resource.url,
            type: resource.type,
          );
          await db.resourceDao.insertResource(resourceEntity);
        }
      }
    }

    return packageId;
  }

  /// Updates an existing package in the database
  static Future<void> updateInDatabase(
    AppDatabase db,
    LearningPackage package,
  ) async {
    if (package.id == null) {
      throw Exception('Cannot update package without an ID');
    }

    // Update the package entity
    final packageEntity = PackageEntity(
      id: package.id,
      author: package.author,
      category: package.category,
      description: package.description,
      iconUrl: package.iconUrl,
      language: package.language,
      lastUpdatedDate: package.lastUpdatedDate,
      level: package.level,
      title: package.title,
      version: package.version,
    );

    await db.packageDao.updatePackage(packageEntity);

    // Clear existing word hierarchy
    await _clearExistingHierarchy(db, package.id!);

    // Insert new word hierarchy
    for (final word in package.words) {
      final wordEntity = WordEntity(packageId: package.id!, text: word.text);
      final wordId = await db.wordDao.insertWord(wordEntity);

      // Insert definitions
      for (final definition in word.definitions) {
        final definitionEntity = DefinitionEntity(
          wordId: wordId,
          text: definition.text,
          source: definition.source,
        );
        await db.definitionDao.insertDefinition(definitionEntity);
      }

      // Insert sentences and their resources
      for (final sentence in word.sentences) {
        final sentenceEntity = SentenceEntity(
          wordId: wordId,
          text: sentence.text,
        );
        final sentenceId = await db.sentenceDao.insertSentence(sentenceEntity);

        // Insert resources
        for (final resource in sentence.resources) {
          final resourceEntity = ResourceEntity(
            sentenceId: sentenceId,
            title: resource.title,
            url: resource.url,
            type: resource.type,
          );
          await db.resourceDao.insertResource(resourceEntity);
        }
      }
    }
  }

  /// Deletes a package and all its related entities from the database
  static Future<void> deleteFromDatabase(AppDatabase db, int packageId) async {
    // Clear the word hierarchy
    await _clearExistingHierarchy(db, packageId);

    // Delete the package entity
    final packageEntity = await db.packageDao.findById(packageId);
    if (packageEntity != null) {
      await db.packageDao.deletePackage(packageEntity);
    }
  }

  /// Helper method to clear existing word hierarchy for a package
  static Future<void> _clearExistingHierarchy(
    AppDatabase db,
    int packageId,
  ) async {
    final existingWords = await db.wordDao.findByPackageId(packageId);

    for (final word in existingWords) {
      final wordId = word.id;
      if (wordId == null) continue;

      // Delete definitions
      final definitions = await db.definitionDao.findForWord(wordId);
      for (final definition in definitions) {
        await db.definitionDao.deleteDefinition(definition);
      }

      // Delete sentences and their resources
      final sentences = await db.sentenceDao.findForWord(wordId);
      for (final sentence in sentences) {
        final sentenceId = sentence.id;
        if (sentenceId != null) {
          final sources = await db.resourceDao.findForSentence(sentenceId);
          for (final source in sources) {
            await db.resourceDao.deleteResource(source);
          }
        }
        await db.sentenceDao.deleteSentence(sentence);
      }

      // Delete the word
      await db.wordDao.deleteWord(word);
    }
  }
}
