import 'package:floor/floor.dart';
import '../entities/sentence_entity.dart';

@dao
abstract class SentenceDao {
  @Query('SELECT * FROM SentenceEntity WHERE wordId = :wordId')
  Future<List<SentenceEntity>> findForWord(int wordId);

  @insert
  Future<int> insertSentence(SentenceEntity sentence);

  @insert
  Future<List<int>> insertSentences(List<SentenceEntity> sentences);

  @update
  Future<void> updateSentence(SentenceEntity sentence);

  @delete
  Future<void> deleteSentence(SentenceEntity sentence);
}
