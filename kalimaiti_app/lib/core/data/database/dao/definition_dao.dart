import 'package:floor/floor.dart';
import '../entities/definition_entity.dart';

@dao
abstract class DefinitionDao {
  @Query('SELECT * FROM DefinitionEntity WHERE wordId = :wordId')
  Future<List<DefinitionEntity>> findForWord(int wordId);

  @insert
  Future<int> insertDefinition(DefinitionEntity definition);

  @insert
  Future<List<int>> insertDefinitions(List<DefinitionEntity> definitions);

  @update
  Future<void> updateDefinition(DefinitionEntity definition);

  @delete
  Future<void> deleteDefinition(DefinitionEntity definition);
}
