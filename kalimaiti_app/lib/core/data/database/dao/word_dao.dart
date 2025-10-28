import 'package:floor/floor.dart';
import '../entities/word_entity.dart';

@dao
abstract class WordDao {
  @Query('SELECT * FROM WordEntity')
  Future<List<WordEntity>> findAllWords();

  @Query('SELECT * FROM WordEntity WHERE packageRemoteId = :packageRemoteId')
  Future<List<WordEntity>> findByPackageRemoteId(String packageRemoteId);

  @Query('SELECT * FROM WordEntity WHERE text LIKE :searchText')
  Future<List<WordEntity>> searchByText(String searchText);

  @insert
  Future<int> insertWord(WordEntity word);

  @insert
  Future<List<int>> insertWords(List<WordEntity> words);

  @update
  Future<void> updateWord(WordEntity word);

  @delete
  Future<void> deleteWord(WordEntity word);
}
