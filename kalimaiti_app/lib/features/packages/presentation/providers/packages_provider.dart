import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/database/entities/package_entity.dart';
import '../../domain/contracts/package_repo.dart';
import 'repoProvider.dart';

class PackagesState {
  final List<PackageEntity> packages;
  final bool isLoading;
  final String? error;

  PackagesState({this.packages = const [], this.isLoading = false, this.error});

  PackagesState copyWith({
    List<PackageEntity>? packages,
    bool? isLoading,
    String? error,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PackagesNotifier extends StateNotifier<PackagesState> {
  final PackageRepository _repository;

  PackagesNotifier(this._repository) : super(PackagesState(isLoading: true)) {
    loadPackages();
  }

  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final packages = await _repository.getAllPackages();
      state = state.copyWith(packages: packages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<int> addPackage(PackageEntity package) async {
    try {
      final id = await _repository.addPackage(package);
      await loadPackages();
      return id;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePackage(PackageEntity package) async {
    try {
      final updatedPackage = package.copyWith(
        version: package.version + 1,
        lastUpdatedDate: DateTime.now().toIso8601String(),
      );
      await _repository.updatePackage(updatedPackage);
      await loadPackages();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePackage(PackageEntity package) async {
    try {
      await _repository.deletePackage(package);
      await loadPackages();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final packagesNotifierProvider =
    StateNotifierProvider<PackagesNotifier, PackagesState>((ref) {
      final repoAsync = ref.watch(packageRepoProvider);
      return repoAsync.when(
        data: (repo) => PackagesNotifier(repo),
        loading: () => PackagesNotifier(_LoadingRepository()),
        error: (err, stack) => throw err,
      );
    });

// Temporary placeholder repository for loading state
class _LoadingRepository implements PackageRepository {
  @override
  Future<List<PackageEntity>> getAllPackages() async => [];

  @override
  Future<PackageEntity?> getPackageById(int id) async => null;

  @override
  Future<List<PackageEntity>> getPackagesByCategory(String category) async =>
      [];

  @override
  Future<List<PackageEntity>> getPackagesByLevel(String level) async => [];

  @override
  Future<int> addPackage(PackageEntity package) async => 0;

  @override
  Future<void> updatePackage(PackageEntity package) async {}

  @override
  Future<void> deletePackage(PackageEntity package) async {}
}
