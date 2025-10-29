import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalimaiti_app/core/data/database/database_provider.dart';
import 'package:kalimaiti_app/features/packages/domain/contracts/package_repo.dart';
import 'package:kalimaiti_app/features/packages/data/repository/package_repo_local_db.dart';

final packageRepoProvider = FutureProvider<PackageRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return PackageRepoLocalDb(db.packageDao);
});
