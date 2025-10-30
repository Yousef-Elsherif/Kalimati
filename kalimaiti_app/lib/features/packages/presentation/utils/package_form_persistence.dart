import '../../../../core/data/database/app_database.dart';
import '../../../../core/data/database/entities/definition_entity.dart';
import '../../../../core/data/database/entities/resource_entity.dart';
import '../../../../core/data/database/entities/sentence_entity.dart';
import '../../../../core/data/database/entities/word_entity.dart';
import '../widgets/package_form.dart';

/// Insert the provided word hierarchy for the given package id.
Future<void> insertPackageWordHierarchy(
  AppDatabase db,
  int packageId,
  List<PackageFormWordSubmission> words,
) async {
  for (final word in words) {
    final wordId = await db.wordDao.insertWord(
      WordEntity(packageId: packageId, text: word.text),
    );

    for (final definition in word.definitions) {
      await db.definitionDao.insertDefinition(
        DefinitionEntity(
          wordId: wordId,
          text: definition.text,
          source: definition.source,
        ),
      );
    }

    for (final sentence in word.sentences) {
      final sentenceId = await db.sentenceDao.insertSentence(
        SentenceEntity(
          wordId: wordId,
          text: sentence.text,
        ),
      );

      for (final source in sentence.sources) {
        await db.resourceDao.insertResource(
          ResourceEntity(
            sentenceId: sentenceId,
            title: source.title,
            url: source.url,
            type: source.type,
          ),
        );
      }
    }
  }
}

/// Replace existing words and nested resources for a package.
Future<void> replacePackageWordHierarchy(
  AppDatabase db,
  int packageId,
  List<PackageFormWordSubmission> words,
) async {
  await _clearExistingHierarchy(db, packageId);
  await insertPackageWordHierarchy(db, packageId, words);
}

Future<void> deletePackageWordHierarchy(
  AppDatabase db,
  int packageId,
) async {
  await _clearExistingHierarchy(db, packageId);
}

Future<void> _clearExistingHierarchy(AppDatabase db, int packageId) async {
  final existingWords = await db.wordDao.findByPackageId(packageId);

  for (final word in existingWords) {
    final wordId = word.id;
    if (wordId == null) continue;

    final definitions = await db.definitionDao.findForWord(wordId);
    for (final definition in definitions) {
      await db.definitionDao.deleteDefinition(definition);
    }

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

    await db.wordDao.deleteWord(word);
  }
}
