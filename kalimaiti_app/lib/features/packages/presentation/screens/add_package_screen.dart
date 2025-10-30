import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/database/database_provider.dart';
import '../../../../core/data/database/entities/definition_entity.dart';
import '../../../../core/data/database/entities/package_entity.dart';
import '../../../../core/data/database/entities/resource_entity.dart';
import '../../../../core/data/database/entities/sentence_entity.dart';
import '../../../../core/data/database/entities/word_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/packages_provider.dart';

class AddPackageScreen extends ConsumerStatefulWidget {
  const AddPackageScreen({super.key});

  @override
  ConsumerState<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends ConsumerState<AddPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _iconUrlController = TextEditingController();
  final List<WordFormData> _wordForms = [WordFormData()];

  static const List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  String _selectedLevel = _levels.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _languageController.dispose();
    _iconUrlController.dispose();
    for (final form in _wordForms) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateWordForms();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to add a package.')),
      );
      return;
    }

    final submissions = _collectWordSubmissions();

    setState(() {
      _isSubmitting = true;
    });

    final now = DateTime.now();
    final package = PackageEntity(
      author: user.email,
      category: _categoryController.text.trim(),
      description: _descriptionController.text.trim(),
      iconUrl: _iconUrlController.text.trim(),
      language: _languageController.text.trim(),
      lastUpdatedDate: now.toIso8601String(),
      level: _selectedLevel,
      title: _titleController.text.trim(),
      version: 1,
    );

    try {
      final packageId =
          await ref.read(packagesNotifierProvider.notifier).addPackage(package);
      final db = await ref.read(databaseProvider.future);

      for (final wordSubmission in submissions) {
        final wordId = await db.wordDao.insertWord(
          WordEntity(packageId: packageId, text: wordSubmission.text),
        );

        for (final definition in wordSubmission.definitions) {
          await db.definitionDao.insertDefinition(
            DefinitionEntity(
              wordId: wordId,
              text: definition.text,
              source: definition.source,
            ),
          );
        }

        for (final sentence in wordSubmission.sentences) {
          final sentenceId = await db.sentenceDao.insertSentence(
            SentenceEntity(
              wordId: wordId,
              text: sentence.text,
            ),
          );

          for (final resource in sentence.resources) {
            await db.resourceDao.insertResource(
              ResourceEntity(
                sentenceId: sentenceId,
                title: resource.title,
                url: resource.url,
                type: resource.type,
              ),
            );
          }
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${package.title}" added successfully.')),
      );
      context.go('/myPackages');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add package: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final packagesState = ref.watch(packagesNotifierProvider);
    final theme = Theme.of(context);

    if (packagesState.isLoading && !_isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create New Package',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share your knowledge by adding a new learning package.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. Introduction to Flutter',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Provide a concise overview of the package contents.',
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().length < 20) {
                  return 'Description should be at least 20 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _categoryController,
              label: 'Category',
              hint: 'e.g. Mobile Development',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: _inputDecoration('Difficulty Level'),
              items: _levels
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLevel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _languageController,
              label: 'Language',
              hint: 'e.g. English',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Language is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _iconUrlController,
              label: 'Icon URL',
              hint: 'Link to a representative image (optional)',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            Text(
              'Words',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._wordForms.asMap().entries.map(
              (entry) => _buildWordCard(entry.key, entry.value),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addWordForm,
                icon: const Icon(Icons.add),
                label: const Text('Add another word'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Package'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(int index, WordFormData wordForm) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Word ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_wordForms.length > 1)
                  IconButton(
                    tooltip: 'Remove word',
                    onPressed: () => _removeWordForm(index),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: wordForm.wordController,
              decoration: _inputDecoration('Word', hint: 'e.g. Vocabulary term'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Word text is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Definitions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...wordForm.definitions.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: entry.value.textController,
                      decoration: _inputDecoration('Definition'),
                      minLines: 2,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Definition text is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: entry.value.sourceController,
                            decoration: _inputDecoration('Source'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Source is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        if (wordForm.definitions.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: IconButton(
                              tooltip: 'Remove definition',
                              onPressed: () => _removeDefinition(
                                index,
                                entry.key,
                              ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addDefinition(index),
                icon: const Icon(Icons.add),
                label: const Text('Add definition'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sentences',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...wordForm.sentences.asMap().entries.map(
              (sentenceEntry) => _buildSentenceCard(
                wordIndex: index,
                sentenceIndex: sentenceEntry.key,
                sentenceForm: sentenceEntry.value,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _addSentence(index),
                icon: const Icon(Icons.add),
                label: const Text('Add sentence'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentenceCard({
    required int wordIndex,
    required int sentenceIndex,
    required SentenceFormData sentenceForm,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: sentenceForm.textController,
                  decoration: _inputDecoration('Sentence'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sentence text is required';
                    }
                    return null;
                  },
                ),
              ),
              if (_wordForms[wordIndex].sentences.length > 1)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    tooltip: 'Remove sentence',
                    onPressed: () => _removeSentence(wordIndex, sentenceIndex),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sources',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...sentenceForm.resources.asMap().entries.map(
            (resourceEntry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildResourceRow(
                wordIndex: wordIndex,
                sentenceIndex: sentenceIndex,
                resourceIndex: resourceEntry.key,
                resourceForm: resourceEntry.value,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addResource(wordIndex, sentenceIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add source'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceRow({
    required int wordIndex,
    required int sentenceIndex,
    required int resourceIndex,
    required ResourceFormData resourceForm,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: resourceForm.titleController,
                  decoration: _inputDecoration('Source title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
              ),
              if (_wordForms[wordIndex]
                      .sentences[sentenceIndex]
                      .resources
                      .length >
                  1)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    tooltip: 'Remove source',
                    onPressed: () => _removeResource(
                      wordIndex,
                      sentenceIndex,
                      resourceIndex,
                    ),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: resourceForm.urlController,
                  decoration: _inputDecoration('Source URL'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'URL is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: resourceForm.typeController,
                  decoration: _inputDecoration('Source type'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Type is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, hint: hint),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  void _addWordForm() {
    setState(() {
      _wordForms.add(WordFormData());
    });
  }

  void _removeWordForm(int index) {
    if (_wordForms.length == 1) return;
    setState(() {
      final removed = _wordForms.removeAt(index);
      removed.dispose();
    });
  }

  void _addDefinition(int wordIndex) {
    setState(() {
      _wordForms[wordIndex].definitions.add(DefinitionFormData());
    });
  }

  void _removeDefinition(int wordIndex, int definitionIndex) {
    final definitions = _wordForms[wordIndex].definitions;
    if (definitions.length == 1) return;
    setState(() {
      final removed = definitions.removeAt(definitionIndex);
      removed.dispose();
    });
  }

  void _addSentence(int wordIndex) {
    setState(() {
      _wordForms[wordIndex].sentences.add(SentenceFormData());
    });
  }

  void _removeSentence(int wordIndex, int sentenceIndex) {
    final sentences = _wordForms[wordIndex].sentences;
    if (sentences.length == 1) return;
    setState(() {
      final removed = sentences.removeAt(sentenceIndex);
      removed.dispose();
    });
  }

  void _addResource(int wordIndex, int sentenceIndex) {
    setState(() {
      _wordForms[wordIndex]
          .sentences[sentenceIndex]
          .resources
          .add(ResourceFormData());
    });
  }

  void _removeResource(int wordIndex, int sentenceIndex, int resourceIndex) {
    final resources =
        _wordForms[wordIndex].sentences[sentenceIndex].resources;
    if (resources.length == 1) return;
    setState(() {
      final removed = resources.removeAt(resourceIndex);
      removed.dispose();
    });
  }

  String? _validateWordForms() {
    if (_wordForms.isEmpty) {
      return 'Please add at least one word.';
    }

    for (var wordIndex = 0; wordIndex < _wordForms.length; wordIndex++) {
      final word = _wordForms[wordIndex];
      final wordText = word.wordController.text.trim();
      if (wordText.isEmpty) {
        return 'Word ${wordIndex + 1} requires text.';
      }

      if (word.definitions.isEmpty) {
        return 'Word ${wordIndex + 1} requires at least one definition.';
      }

      for (var defIndex = 0;
          defIndex < word.definitions.length;
          defIndex++) {
        final definition = word.definitions[defIndex];
        if (definition.textController.text.trim().isEmpty) {
          return 'Definition ${defIndex + 1} for word ${wordIndex + 1} requires text.';
        }
        if (definition.sourceController.text.trim().isEmpty) {
          return 'Definition ${defIndex + 1} for word ${wordIndex + 1} requires a source.';
        }
      }

      if (word.sentences.isEmpty) {
        return 'Word ${wordIndex + 1} requires at least one sentence.';
      }

      for (var sentenceIndex = 0;
          sentenceIndex < word.sentences.length;
          sentenceIndex++) {
        final sentence = word.sentences[sentenceIndex];
        if (sentence.textController.text.trim().isEmpty) {
          return 'Sentence ${sentenceIndex + 1} for word ${wordIndex + 1} requires text.';
        }

        if (sentence.resources.isEmpty) {
          return 'Sentence ${sentenceIndex + 1} for word ${wordIndex + 1} requires at least one resource.';
        }

        for (var resourceIndex = 0;
            resourceIndex < sentence.resources.length;
            resourceIndex++) {
          final resource = sentence.resources[resourceIndex];
          if (resource.titleController.text.trim().isEmpty) {
            return 'Resource ${resourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a title.';
          }
          if (resource.urlController.text.trim().isEmpty) {
            return 'Resource ${resourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a URL.';
          }
          if (resource.typeController.text.trim().isEmpty) {
            return 'Resource ${resourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a type.';
          }
        }
      }
    }

    return null;
  }

  List<_WordSubmission> _collectWordSubmissions() {
    return _wordForms.map((wordForm) {
      final definitions = wordForm.definitions
          .map(
            (definition) => _DefinitionSubmission(
              text: definition.textController.text.trim(),
              source: definition.sourceController.text.trim(),
            ),
          )
          .toList();

      final sentences = wordForm.sentences.map((sentenceForm) {
        final resources = sentenceForm.resources
            .map(
              (resourceForm) => _ResourceSubmission(
                title: resourceForm.titleController.text.trim(),
                url: resourceForm.urlController.text.trim(),
                type: resourceForm.typeController.text.trim(),
              ),
            )
            .toList();

        return _SentenceSubmission(
          text: sentenceForm.textController.text.trim(),
          resources: resources,
        );
      }).toList();

      return _WordSubmission(
        text: wordForm.wordController.text.trim(),
        definitions: definitions,
        sentences: sentences,
      );
    }).toList();
  }
}

class WordFormData {
  WordFormData()
      : wordController = TextEditingController(),
        definitions = [DefinitionFormData()],
        sentences = [SentenceFormData()];

  final TextEditingController wordController;
  final List<DefinitionFormData> definitions;
  final List<SentenceFormData> sentences;

  void dispose() {
    wordController.dispose();
    for (final definition in definitions) {
      definition.dispose();
    }
    for (final sentence in sentences) {
      sentence.dispose();
    }
  }
}

class DefinitionFormData {
  DefinitionFormData()
      : textController = TextEditingController(),
        sourceController = TextEditingController();

  final TextEditingController textController;
  final TextEditingController sourceController;

  void dispose() {
    textController.dispose();
    sourceController.dispose();
  }
}

class SentenceFormData {
  SentenceFormData()
      : textController = TextEditingController(),
        resources = [ResourceFormData()];

  final TextEditingController textController;
  final List<ResourceFormData> resources;

  void dispose() {
    textController.dispose();
    for (final resource in resources) {
      resource.dispose();
    }
  }
}

class ResourceFormData {
  ResourceFormData()
      : titleController = TextEditingController(),
        urlController = TextEditingController(),
        typeController = TextEditingController();

  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController typeController;

  void dispose() {
    titleController.dispose();
    urlController.dispose();
    typeController.dispose();
  }
}

class _WordSubmission {
  _WordSubmission({
    required this.text,
    required this.definitions,
    required this.sentences,
  });

  final String text;
  final List<_DefinitionSubmission> definitions;
  final List<_SentenceSubmission> sentences;
}

class _DefinitionSubmission {
  _DefinitionSubmission({required this.text, required this.source});

  final String text;
  final String source;
}

class _SentenceSubmission {
  _SentenceSubmission({required this.text, required this.resources});

  final String text;
  final List<_ResourceSubmission> resources;
}

class _ResourceSubmission {
  _ResourceSubmission({
    required this.title,
    required this.url,
    required this.type,
  });

  final String title;
  final String url;
  final String type;
}
