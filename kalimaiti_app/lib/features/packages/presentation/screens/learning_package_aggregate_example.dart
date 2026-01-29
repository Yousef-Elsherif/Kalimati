import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/learning_package.dart';
import '../providers/repoProvider.dart';

/// Example screen showing how to use the LearningPackage aggregate
class LearningPackageAggregateExample extends ConsumerWidget {
  const LearningPackageAggregateExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Package Aggregate Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Example 1: Save a complete package
          ElevatedButton(
            onPressed: () async {
              final repository = await ref.read(packageRepoProvider.future);

              // Create a complete package as an aggregate
              final package = LearningPackage(
                author: 'user@example.com',
                category: 'vocabulary',
                description: 'Learn Spanish basics',
                iconUrl: 'https://example.com/icon.png',
                language: 'Spanish',
                lastUpdatedDate: DateTime.now().toIso8601String(),
                level: 'beginner',
                title: 'Spanish Basics',
                version: 1,
                words: [
                  Word(
                    text: 'hola',
                    definitions: [
                      Definition(text: 'hello', source: 'dictionary'),
                    ],
                    sentences: [
                      Sentence(
                        text: 'Hola, ¿cómo estás?',
                        resources: [
                          Resource(
                            title: 'Video',
                            url: 'https://example.com/video',
                            type: 'video',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );

              // Save the entire package as a single operation
              final packageId = await repository.saveLearningPackage(package);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Package saved with ID: $packageId')),
                );
              }
            },
            child: const Text('Save Complete Package'),
          ),

          const SizedBox(height: 16),

          // Example 2: Load a complete package
          ElevatedButton(
            onPressed: () async {
              final repository = await ref.read(packageRepoProvider.future);

              // Get the entire package as a single aggregate
              final package = await repository.getLearningPackageById(1);

              if (package != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Loaded: ${package.title} with ${package.words.length} words',
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Load Package by ID'),
          ),

          const SizedBox(height: 16),

          // Example 3: Export package to JSON
          ElevatedButton(
            onPressed: () async {
              final repository = await ref.read(packageRepoProvider.future);

              // Export the package as a JSON string
              final jsonString = await repository.exportLearningPackageAsJson(
                1,
              );

              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Exported JSON'),
                    content: SingleChildScrollView(child: Text(jsonString)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Export Package to JSON'),
          ),

          const SizedBox(height: 16),

          // Example 4: Import package from JSON
          ElevatedButton(
            onPressed: () async {
              final repository = await ref.read(packageRepoProvider.future);

              // Sample JSON string
              const jsonString = '''
{
  "author": "imported@example.com",
  "category": "grammar",
  "description": "Imported package",
  "iconUrl": "https://example.com/icon.png",
  "language": "French",
  "lastUpdatedDate": "2025-11-07T10:30:00.000Z",
  "level": "intermediate",
  "title": "French Grammar",
  "version": 1,
  "words": [
    {
      "text": "bonjour",
      "definitions": [
        {
          "text": "good morning",
          "source": "dictionary"
        }
      ],
      "sentences": [
        {
          "text": "Bonjour, comment allez-vous?",
          "resources": []
        }
      ]
    }
  ]
}
              ''';

              // Import the package
              final packageId = await repository.importLearningPackageFromJson(
                jsonString,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Package imported with ID: $packageId'),
                  ),
                );
              }
            },
            child: const Text('Import Package from JSON'),
          ),

          const SizedBox(height: 16),

          // Example 5: Update a package
          ElevatedButton(
            onPressed: () async {
              final repository = await ref.read(packageRepoProvider.future);

              // Get existing package
              final package = await repository.getLearningPackageById(1);

              if (package != null) {
                // Update using copyWith
                final updatedPackage = package.copyWith(
                  title: '${package.title} - Updated',
                  version: package.version + 1,
                  lastUpdatedDate: DateTime.now().toIso8601String(),
                );

                // Save the update
                await repository.updateLearningPackage(updatedPackage);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Package updated')),
                  );
                }
              }
            },
            child: const Text('Update Package'),
          ),

          const SizedBox(height: 32),

          const Text(
            'Benefits of Aggregate Pattern:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Entire package saved/loaded as single unit\n'
            '• Easy JSON serialization for export/import\n'
            '• Ready for document databases (Azure Cosmos DB)\n'
            '• Maintains data consistency\n'
            '• Simpler code - no manual cascading operations',
          ),
        ],
      ),
    );
  }
}
