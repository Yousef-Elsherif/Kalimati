import 'dart:io';
import '../domain/models/learning_package.dart';
import '../domain/contracts/package_repo.dart';

// Utility class for importing and exporting learning packages as JSON
class LearningPackageImportExport {
  final PackageRepository repository;

  LearningPackageImportExport(this.repository);

  // Exports a learning package to a JSON file
  Future<void> exportToFile(int packageId, String filePath) async {
    final jsonString = await repository.exportLearningPackageAsJson(packageId);
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  // Imports a learning package from a JSON file
  Future<int> importFromFile(String filePath) async {
    final file = File(filePath);
    final jsonString = await file.readAsString();
    return repository.importLearningPackageFromJson(jsonString);
  }

  // Exports a learning package to a JSON string
  Future<String> exportToString(int packageId) async {
    return repository.exportLearningPackageAsJson(packageId);
  }

  // Imports a learning package from a JSON string
  Future<int> importFromString(String jsonString) async {
    return repository.importLearningPackageFromJson(jsonString);
  }

  // Creates a learning package directly from a LearningPackage object
  Future<int> importPackage(LearningPackage package) async {
    // Remove ID to ensure a new package is created
    final newPackage = package.copyWith(id: null);
    return repository.saveLearningPackage(newPackage);
  }

  // Gets a learning package as an aggregate object
  Future<LearningPackage?> getPackage(int packageId) async {
    return repository.getLearningPackageById(packageId);
  }

  // Updates a learning package
  Future<void> updatePackage(LearningPackage package) async {
    return repository.updateLearningPackage(package);
  }
}
