import 'package:kalimaiti_app/core/data/database/entities/package_entity.dart';
import '../models/learning_package.dart';

abstract class PackageRepository {
  // Legacy methods for backward compatibility
  Future<List<PackageEntity>> getAllPackages();
  Future<PackageEntity?> getPackageById(int id);
  Future<List<PackageEntity>> getPackagesByCategory(String category);
  Future<List<PackageEntity>> getPackagesByLevel(String level);
  Future<int> addPackage(PackageEntity package);
  Future<void> updatePackage(PackageEntity package);
  Future<void> deletePackage(PackageEntity package);

  // New aggregate-based methods
  /// Gets a complete learning package as an aggregate
  Future<LearningPackage?> getLearningPackageById(int id);

  /// Gets all learning packages as aggregates
  Future<List<LearningPackage>> getAllLearningPackages();

  /// Saves a complete learning package as an aggregate
  Future<int> saveLearningPackage(LearningPackage package);

  /// Updates a complete learning package as an aggregate
  Future<void> updateLearningPackage(LearningPackage package);

  /// Deletes a learning package by ID
  Future<void> deleteLearningPackageById(int id);

  /// Exports a learning package as a JSON string
  Future<String> exportLearningPackageAsJson(int id);

  /// Imports a learning package from a JSON string
  Future<int> importLearningPackageFromJson(String jsonString);
}
