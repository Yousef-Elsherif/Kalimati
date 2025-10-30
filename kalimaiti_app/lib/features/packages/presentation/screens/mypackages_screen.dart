import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kalimaiti_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../../core/data/database/entities/package_entity.dart';
import '../providers/packages_provider.dart';
import '../widgets/packages_listing.dart';

class MyPackagesScreen extends ConsumerWidget {
  const MyPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesState = ref.watch(packagesNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

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

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your packages.'),
      );
    }

    final myPackages = packagesState.packages
        .where((pkg) => pkg.author.toLowerCase() == user.email.toLowerCase())
        .toList();

    if (myPackages.isEmpty) {
      return const Center(
        child: Text('You have not created any packages yet.'),
      );
    }

    return PackagesListing(
      packages: myPackages,
      showOwnerActions: true,
      onEditPackage: (PackageEntity package) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit ${package.title} tapped'),
          ),
        );
      },
      onDeletePackage: (PackageEntity package) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Package'),
            content: Text(
              'Are you sure you want to delete "${package.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          await ref
              .read(packagesNotifierProvider.notifier)
              .deletePackage(package);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${package.title}" deleted'),
            ),
          );
        }
      },
      onPackageSelected: (PackageEntity package) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${package.title}'),
          ),
        );
      },
    );
  }
}
