import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/database/database_provider.dart';
import '../../../../core/data/database/entities/package_entity.dart';
import '../../../../core/data/database/entities/resource_entity.dart';
import '../providers/packages_provider.dart';
import '../utils/package_form_persistence.dart';
import '../widgets/package_form.dart';

class EditPackageScreen extends ConsumerStatefulWidget {
  const EditPackageScreen({required this.packageId, super.key});

  final int packageId;

  @override
  ConsumerState<EditPackageScreen> createState() => _EditPackageScreenState();
}

class _EditPackageScreenState extends ConsumerState<EditPackageScreen> {
  PackageEntity? _package;
  List<PackageFormWordData> _initialWords = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPackage();
  }

  Future<void> _loadPackage() async {
    try {
      final db = await ref.read(databaseProvider.future);
      final package = await db.packageDao.findById(widget.packageId);
      if (package == null) {
        setState(() {
          _error = 'Package not found';
          _isLoading = false;
        });
        return;
      }

      final wordEntities = await db.wordDao.findByPackageId(widget.packageId);
      final wordData = <PackageFormWordData>[];

      for (final word in wordEntities) {
        final wordId = word.id;
        if (wordId == null) continue;

        final definitions = await db.definitionDao.findForWord(wordId);
        final sentences = await db.sentenceDao.findForWord(wordId);

        final definitionData = definitions
            .map(
              (definition) => PackageFormDefinitionData(
                text: definition.text,
                source: definition.source,
              ),
            )
            .toList();

        final sentenceData = <PackageFormSentenceData>[];
        for (final sentence in sentences) {
          final sentenceId = sentence.id;
          final sources = sentenceId == null
              ? <ResourceEntity>[]
              : await db.resourceDao.findForSentence(sentenceId);

          final sourceData = sources
              .map(
                (source) => PackageFormSourceData(
                  title: source.title,
                  url: source.url,
                  type: source.type,
                ),
              )
              .toList();

          sentenceData.add(
            PackageFormSentenceData(text: sentence.text, sources: sourceData),
          );
        }

        wordData.add(
          PackageFormWordData(
            text: word.text,
            definitions: definitionData,
            sentences: sentenceData,
          ),
        );
      }

      setState(() {
        _package = package;
        _initialWords = wordData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load package: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSubmit(PackageFormResult result) async {
    final existing = _package;
    if (existing == null) return;

    final updated = existing.copyWith(
      category: result.category,
      description: result.description,
      iconUrl: result.iconUrl,
      language: result.language,
      level: result.level,
      title: result.title,
    );

    try {
      await ref.read(packagesNotifierProvider.notifier).updatePackage(updated);
      final db = await ref.read(databaseProvider.future);
      await replacePackageWordHierarchy(db, existing.id!, result.words);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package updated successfully.')),
      );
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update package: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Package')),
        body: Center(child: Text(_error!)),
      );
    }

    final package = _package;
    if (package == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(package.title),
        actions: [
          IconButton(
            tooltip: 'Delete package',
            icon: const Icon(Icons.delete_outline),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: PackageForm(
        initialPackage: package,
        initialWords: _initialWords,
        onSubmit: _handleSubmit,
      ),
    );
  }

  Future<void> _handleDelete() async {
    final package = _package;
    final packageId = package?.id;
    if (package == null || packageId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${package.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final db = await ref.read(databaseProvider.future);
    await deletePackageWordHierarchy(db, packageId);
    await ref.read(packagesNotifierProvider.notifier).deletePackage(package);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${package.title}" deleted')));
    context.pop();
  }
}
