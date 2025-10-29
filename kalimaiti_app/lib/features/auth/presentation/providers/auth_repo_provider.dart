import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalimaiti_app/core/data/database/database_provider.dart';
import 'package:kalimaiti_app/features/auth/data/repository/auth_repository_local_db.dart';
import 'package:kalimaiti_app/features/auth/domain/contracts/auth_repository.dart';

final authRepoProvider = FutureProvider<AuthRepository>((ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AuthRepositoryLocalDb(db.userDao);
});
