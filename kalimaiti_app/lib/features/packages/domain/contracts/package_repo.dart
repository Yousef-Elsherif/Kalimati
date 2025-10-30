import 'package:kalimaiti_app/core/data/database/entities/package_entity.dart';

abstract class PackageRepository {
  Future<List<PackageEntity>> getAllPackages();
  Future<PackageEntity?> getPackageById(int id);
  Future<List<PackageEntity>> getPackagesByCategory(String category);
  Future<List<PackageEntity>> getPackagesByLevel(String level);
  Future<int> addPackage(PackageEntity package);
  Future<void> updatePackage(PackageEntity package);
  Future<void> deletePackage(PackageEntity package);
}
