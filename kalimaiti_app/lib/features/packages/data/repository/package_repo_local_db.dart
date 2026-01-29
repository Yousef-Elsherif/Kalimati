import 'package:kalimaiti_app/core/data/database/dao/package_dao.dart';
import 'package:kalimaiti_app/core/data/database/entities/package_entity.dart';
import 'package:kalimaiti_app/features/packages/domain/contracts/package_repo.dart';
import 'package:kalimaiti_app/core/data/database/app_database.dart';
import 'package:kalimaiti_app/features/packages/domain/models/learning_package.dart';
import '../mappers/learning_package_mapper.dart';

class PackageRepoLocalDb implements PackageRepository {
  final PackageDao _packageDao;
  final AppDatabase _db;

  PackageRepoLocalDb(this._packageDao, this._db);

  // Legacy methods for backward compatibility
  @override
  Future<List<PackageEntity>> getAllPackages() {
    return _packageDao.findAllPackages();
  }

  @override
  Future<PackageEntity?> getPackageById(int id) {
    return _packageDao.findById(id);
  }

  @override
  Future<List<PackageEntity>> getPackagesByCategory(String category) {
    return _packageDao.findByCategory(category);
  }

  @override
  Future<List<PackageEntity>> getPackagesByLevel(String level) {
    return _packageDao.findByLevel(level);
  }

  @override
  Future<int> addPackage(PackageEntity package) {
    return _packageDao.insertPackage(package);
  }

  @override
  Future<void> updatePackage(PackageEntity package) {
    return _packageDao.updatePackage(package);
  }

  @override
  Future<void> deletePackage(PackageEntity package) {
    return _packageDao.deletePackage(package);
  }

  // New aggregate-based methods
  @override
  Future<LearningPackage?> getLearningPackageById(int id) async {
    final packageEntity = await _packageDao.findById(id);
    if (packageEntity == null) {
      return null;
    }
    return LearningPackageMapper.fromDatabase(_db, packageEntity);
  }

  @override
  Future<List<LearningPackage>> getAllLearningPackages() async {
    final packageEntities = await _packageDao.findAllPackages();
    final learningPackages = <LearningPackage>[];

    for (final entity in packageEntities) {
      final learningPackage = await LearningPackageMapper.fromDatabase(
        _db,
        entity,
      );
      learningPackages.add(learningPackage);
    }

    return learningPackages;
  }

  @override
  Future<int> saveLearningPackage(LearningPackage package) async {
    return LearningPackageMapper.toDatabase(_db, package);
  }

  @override
  Future<void> updateLearningPackage(LearningPackage package) async {
    return LearningPackageMapper.updateInDatabase(_db, package);
  }

  @override
  Future<void> deleteLearningPackageById(int id) async {
    return LearningPackageMapper.deleteFromDatabase(_db, id);
  }

  @override
  Future<String> exportLearningPackageAsJson(int id) async {
    final learningPackage = await getLearningPackageById(id);
    if (learningPackage == null) {
      throw Exception('Learning package with ID $id not found');
    }
    return learningPackage.toJsonString();
  }

  @override
  Future<int> importLearningPackageFromJson(String jsonString) async {
    final learningPackage = LearningPackage.fromJsonString(jsonString);
    // Remove the ID to ensure a new package is created
    final newPackage = learningPackage.copyWith(id: null);
    return saveLearningPackage(newPackage);
  }
}
