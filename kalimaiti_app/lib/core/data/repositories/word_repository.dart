import '../database/app_database.dart';
import '../database/entities/word_entity.dart';
import '../database/entities/definition_entity.dart';
import '../database/entities/sentence_entity.dart';
import '../database/helpers/database_helper.dart';

class WordRepository {
  late AppDatabase _database;

  Future<void> init() async {
    _database = await DatabaseHelper.getDatabase();
  }

  Future<List<WordEntity>> getAllWords() async {
    return await _database.wordDao.findAllWords();
  }

  Future<List<WordEntity>> getWordsByPackageId(String packageRemoteId) async {
    return await _database.wordDao.findByPackageRemoteId(packageRemoteId);
  }

  Future<List<WordEntity>> searchWords(String searchText) async {
    return await _database.wordDao.searchByText('%$searchText%');
  }

  Future<List<DefinitionEntity>> getDefinitionsForWord(int wordId) async {
    return await _database.definitionDao.findForWord(wordId);
  }

  Future<List<SentenceEntity>> getSentencesForWord(int wordId) async {
    return await _database.sentenceDao.findForWord(wordId);
  }

  Future<int> addWord(WordEntity word) async {
    return await _database.wordDao.insertWord(word);
  }

  Future<void> updateWord(WordEntity word) async {
    await _database.wordDao.updateWord(word);
  }

  Future<void> deleteWord(WordEntity word) async {
    await _database.wordDao.deleteWord(word);
  }
}
