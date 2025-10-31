import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalimaiti_app/core/data/database/database_provider.dart';
import 'package:kalimaiti_app/core/data/database/entities/definition_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/resource_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';

final packageWordsProvider = FutureProvider.family<List<WordEntity>, int>((
  ref,
  packageId,
) async {
  final db = await ref.watch(databaseProvider.future);
  final words = await db.wordDao.findByPackageId(packageId);
  final sortedWords = [...words]..sort((a, b) => a.text.compareTo(b.text));
  return sortedWords;
});

final wordSentencesProvider = FutureProvider.family<List<SentenceEntity>, int>((
  ref,
  wordId,
) async {
  final db = await ref.watch(databaseProvider.future);
  return db.sentenceDao.findForWord(wordId);
});

class WordDefinitionPair {
  const WordDefinitionPair({required this.word, required this.definition});

  final WordEntity word;
  final DefinitionEntity definition;
}

final packageWordDefinitionPairsProvider =
    FutureProvider.family<List<WordDefinitionPair>, int>((
      ref,
      packageId,
    ) async {
      final db = await ref.watch(databaseProvider.future);
      final words = await db.wordDao.findByPackageId(packageId);
      final pairs = <WordDefinitionPair>[];

      for (final word in words) {
        final wordId = word.id;
        if (wordId == null) continue;
        final definitions = await db.definitionDao.findForWord(wordId);
        if (definitions.isEmpty) continue;
        pairs.add(
          WordDefinitionPair(word: word, definition: definitions.first),
        );
      }

      return pairs;
    });

class WordSentenceBundle {
  const WordSentenceBundle({required this.sentence, required this.resources});

  final SentenceEntity sentence;
  final List<ResourceEntity> resources;
}

class WordLearningBundle {
  const WordLearningBundle({
    required this.definitions,
    required this.sentences,
  });

  final List<DefinitionEntity> definitions;
  final List<WordSentenceBundle> sentences;
}

final wordLearningBundleProvider =
    FutureProvider.family<WordLearningBundle, int>((ref, wordId) async {
      final db = await ref.watch(databaseProvider.future);
      final definitions = await db.definitionDao.findForWord(wordId);
      final sentences = await db.sentenceDao.findForWord(wordId);

      final sentenceBundles = <WordSentenceBundle>[];
      for (final sentence in sentences) {
        final sentenceId = sentence.id;
        if (sentenceId == null) continue;
        final resources = await db.resourceDao.findForSentence(sentenceId);
        sentenceBundles.add(
          WordSentenceBundle(sentence: sentence, resources: resources),
        );
      }

      return WordLearningBundle(
        definitions: definitions,
        sentences: sentenceBundles,
      );
    });
