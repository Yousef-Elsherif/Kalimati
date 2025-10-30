import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalimaiti_app/core/data/database/database_provider.dart';
import 'package:kalimaiti_app/core/data/database/entities/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';

final packageWordsProvider =
    FutureProvider.family<List<WordEntity>, int>((ref, packageId) async {
  final db = await ref.watch(databaseProvider.future);
  final words = await db.wordDao.findByPackageId(packageId);
  final sortedWords = [...words]..sort((a, b) => a.text.compareTo(b.text));
  return sortedWords;
});

final wordSentencesProvider =
    FutureProvider.family<List<SentenceEntity>, int>((ref, wordId) async {
  final db = await ref.watch(databaseProvider.future);
  return db.sentenceDao.findForWord(wordId);
});
