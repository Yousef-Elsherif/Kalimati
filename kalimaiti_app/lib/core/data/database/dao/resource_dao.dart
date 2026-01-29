import 'package:floor/floor.dart';
import '../entities/resource_entity.dart';

@dao
abstract class ResourceDao {
  @Query('SELECT * FROM ResourceEntity WHERE sentenceId = :sentenceId')
  Future<List<ResourceEntity>> findForSentence(int sentenceId);

  @insert
  Future<int> insertResource(ResourceEntity resource);

  @insert
  Future<List<int>> insertResources(List<ResourceEntity> resources);

  @update
  Future<void> updateResource(ResourceEntity resource);

  @delete
  Future<void> deleteResource(ResourceEntity resource);
}
