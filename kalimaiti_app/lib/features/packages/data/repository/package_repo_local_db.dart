import 'package:kalimaiti_app/core/data/database/dao/package_dao.dart';
import 'package:kalimaiti_app/core/data/database/entities/package_entity.dart';
import 'package:kalimaiti_app/features/packages/domain/contracts/package_repo.dart';

class PackageRepoLocalDb implements PackageRepository {
  final PackageDao _packageDao;
  PackageRepoLocalDb(this._packageDao);

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
}
