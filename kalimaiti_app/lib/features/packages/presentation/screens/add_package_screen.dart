import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/database/database_provider.dart';
import '../../../../core/data/database/entities/package_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/packages_provider.dart';
import '../utils/package_form_persistence.dart';
import '../widgets/package_form.dart';

class AddPackageScreen extends ConsumerStatefulWidget {
  const AddPackageScreen({super.key});

  @override
  ConsumerState<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends ConsumerState<AddPackageScreen> {
  Future<void> _handleSubmit(PackageFormResult result) async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add a package.')),
      );
      return;
    }

    final now = DateTime.now();
    final package = PackageEntity(
      author: user.email,
      category: result.category,
      description: result.description,
      iconUrl: result.iconUrl,
      language: result.language,
      lastUpdatedDate: now.toIso8601String(),
      level: result.level,
      title: result.title,
      version: 1,
    );

    try {
      final notifier = ref.read(packagesNotifierProvider.notifier);
      final packageId = await notifier.addPackage(package);
      final db = await ref.read(databaseProvider.future);
      await insertPackageWordHierarchy(db, packageId, result.words);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${result.title}" added successfully.')),
      );
      if (!mounted) return;
      context.go('/myPackages');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add package: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PackageForm(
      onSubmit: _handleSubmit,
    );
  }
}
