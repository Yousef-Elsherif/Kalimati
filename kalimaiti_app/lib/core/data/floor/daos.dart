import 'package:floor/floor.dart';
import 'package:kalimaiti_app/core/data/floor/user_entity.dart';
import 'package:kalimaiti_app/core/data/floor/package_entity.dart';
import 'package:kalimaiti_app/core/data/floor/word_entity.dart';
import 'package:kalimaiti_app/core/data/floor/definition_entity.dart';
import 'package:kalimaiti_app/core/data/floor/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/floor/resource_entity.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM UserEntity')
  Future<List<UserEntity>> findAllUsers();

  @insert
  Future<List<int>> insertUsers(List<UserEntity> users);
}

@dao
abstract class PackageDao {
  @Query('SELECT * FROM PackageEntity')
  Future<List<PackageEntity>> findAllPackages();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertPackage(PackageEntity package);

  @insert
  Future<List<int>> insertPackages(List<PackageEntity> packages);
}

@dao
abstract class WordDao {
  @Query('SELECT * FROM WordEntity')
  Future<List<WordEntity>> findAllWords();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertWord(WordEntity word);

  @insert
  Future<List<int>> insertWords(List<WordEntity> words);
}

@dao
abstract class DefinitionDao {
  @Query('SELECT * FROM DefinitionEntity WHERE wordId = :wordId')
  Future<List<DefinitionEntity>> findForWord(int wordId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDefinition(DefinitionEntity def);

  @insert
  Future<List<int>> insertDefinitions(List<DefinitionEntity> defs);
}

@dao
abstract class SentenceDao {
  @Query('SELECT * FROM SentenceEntity WHERE wordId = :wordId')
  Future<List<SentenceEntity>> findForWord(int wordId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertSentence(SentenceEntity s);

  @insert
  Future<List<int>> insertSentences(List<SentenceEntity> s);
}

@dao
abstract class ResourceDao {
  @Query('SELECT * FROM ResourceEntity WHERE sentenceId = :sentenceId')
  Future<List<ResourceEntity>> findForSentence(int sentenceId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertResource(ResourceEntity r);

  @insert
  Future<List<int>> insertResources(List<ResourceEntity> r);
}
