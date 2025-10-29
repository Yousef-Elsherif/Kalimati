// import '../database/app_database.dart';
// import '../database/entities/package_entity.dart';
// import '../database/database_provider.dart';

// class PackageRepository {
//   late AppDatabase _database;

//   Future<void> init() async {
//     _database = await DatabaseHelper.getDatabase();
//   }

//   Future<List<PackageEntity>> getAllPackages() async {
//     return await _database.packageDao.findAllPackages();
//   }

//   Future<PackageEntity?> getPackageByRemoteId(String packageRemoteId) async {
//     return await _database.packageDao.findByRemoteId(packageRemoteId);
//   }

//   Future<List<PackageEntity>> getPackagesByCategory(String category) async {
//     return await _database.packageDao.findByCategory(category);
//   }

//   Future<List<PackageEntity>> getPackagesByLevel(String level) async {
//     return await _database.packageDao.findByLevel(level);
//   }

//   Future<int> addPackage(PackageEntity package) async {
//     return await _database.packageDao.insertPackage(package);
//   }

//   Future<void> updatePackage(PackageEntity package) async {
//     await _database.packageDao.updatePackage(package);
//   }

//   Future<void> deletePackage(PackageEntity package) async {
//     await _database.packageDao.deletePackage(package);
//   }
// }
