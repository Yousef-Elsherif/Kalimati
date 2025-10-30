import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/database/entities/package_entity.dart';
import '../widgets/packages_listing.dart';
import '../providers/packages_provider.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesState = ref.watch(packagesNotifierProvider);

    if (packagesState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (packagesState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading packages',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              packagesState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }

    return PackagesListing(
      packages: packagesState.packages,
      onPackageSelected: (PackageEntity package) {
        context.push('/packages/${package.id}');
      },
    );
  }
}
