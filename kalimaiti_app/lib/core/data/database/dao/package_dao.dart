import 'package:floor/floor.dart';
import '../entities/package_entity.dart';

@dao
abstract class PackageDao {
  @Query('SELECT * FROM PackageEntity')
  Future<List<PackageEntity>> findAllPackages();

  @Query('SELECT * FROM PackageEntity WHERE packageRemoteId = :packageRemoteId')
  Future<PackageEntity?> findByRemoteId(String packageRemoteId);

  @Query('SELECT * FROM PackageEntity WHERE category = :category')
  Future<List<PackageEntity>> findByCategory(String category);

  @Query('SELECT * FROM PackageEntity WHERE level = :level')
  Future<List<PackageEntity>> findByLevel(String level);

  @insert
  Future<int> insertPackage(PackageEntity package);

  @insert
  Future<List<int>> insertPackages(List<PackageEntity> packages);

  @update
  Future<void> updatePackage(PackageEntity package);

  @delete
  Future<void> deletePackage(PackageEntity package);
}
