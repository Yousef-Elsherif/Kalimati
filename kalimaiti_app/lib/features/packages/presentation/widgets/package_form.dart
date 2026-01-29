import 'package:flutter/material.dart';

import '../../../../core/data/database/entities/package_entity.dart';

class PackageFormResult {
  PackageFormResult({
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.language,
    required this.iconUrl,
    required this.words,
  });

  final String title;
  final String description;
  final String category;
  final String level;
  final String language;
  final String iconUrl;
  final List<PackageFormWordSubmission> words;
}

class PackageFormWordSubmission {
  PackageFormWordSubmission({
    required this.text,
    required this.definitions,
    required this.sentences,
  });

  final String text;
  final List<PackageFormDefinitionSubmission> definitions;
  final List<PackageFormSentenceSubmission> sentences;
}

class PackageFormDefinitionSubmission {
  PackageFormDefinitionSubmission({required this.text, required this.source});

  final String text;
  final String source;
}

class PackageFormSentenceSubmission {
  PackageFormSentenceSubmission({required this.text, required this.sources});

  final String text;
  final List<PackageFormSourceSubmission> sources;
}

class PackageFormSourceSubmission {
  PackageFormSourceSubmission({
    required this.title,
    required this.url,
    required this.type,
  });

  final String title;
  final String url;
  final String type;
}

class PackageFormWordData {
  const PackageFormWordData({
    required this.text,
    required this.definitions,
    required this.sentences,
  });

  final String text;
  final List<PackageFormDefinitionData> definitions;
  final List<PackageFormSentenceData> sentences;
}

class PackageFormDefinitionData {
  const PackageFormDefinitionData({required this.text, required this.source});

  final String text;
  final String source;
}

class PackageFormSentenceData {
  const PackageFormSentenceData({required this.text, required this.sources});

  final String text;
  final List<PackageFormSourceData> sources;
}

class PackageFormSourceData {
  const PackageFormSourceData({
    required this.title,
    required this.url,
    required this.type,
  });

  final String title;
  final String url;
  final String type;
}

class PackageForm extends StatefulWidget {
  const PackageForm({
    this.initialPackage,
    this.initialWords = const [],
    required this.onSubmit,
    super.key,
  });

  final PackageEntity? initialPackage;
  final List<PackageFormWordData> initialWords;
  final Future<void> Function(PackageFormResult result) onSubmit;

  @override
  State<PackageForm> createState() => _PackageFormState();
}

class _PackageFormState extends State<PackageForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _languageController;
  late final TextEditingController _iconUrlController;
  late List<_WordFormState> _words;
  late String _selectedLevel;
  bool _isSubmitting = false;

  static const List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPackage;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _categoryController = TextEditingController(text: initial?.category ?? '');
    _languageController = TextEditingController(text: initial?.language ?? '');
    _iconUrlController = TextEditingController(text: initial?.iconUrl ?? '');
    _selectedLevel = initial?.level ?? _levels.first;

    if (widget.initialWords.isEmpty) {
      _words = [_WordFormState.empty()];
    } else {
      _words = widget.initialWords
          .map((word) => _WordFormState.fromInitial(word))
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _languageController.dispose();
    _iconUrlController.dispose();
    for (final word in _words) {
      word.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryField(),
            const SizedBox(height: 16),
            _buildLevelField(),
            const SizedBox(height: 16),
            _buildLanguageField(),
            const SizedBox(height: 16),
            _buildIconField(),
            const SizedBox(height: 24),
            _buildWordsSection(theme),
            const SizedBox(height: 24),
            _buildSubmitButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final isEditing = widget.initialPackage != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing ? 'Edit Package' : 'Create New Package',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          isEditing
              ? 'Update the details for this learning package.'
              : 'Share your knowledge by adding a new learning package.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() => _buildTextField(
    controller: _titleController,
    label: 'Title',
    hint: 'e.g. Introduction to Flutter',
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Title is required';
      }
      return null;
    },
  );

  Widget _buildDescriptionField() => _buildTextField(
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
  );

  Widget _buildCategoryField() => _buildTextField(
    controller: _categoryController,
    label: 'Category',
    hint: 'e.g. Mobile Development',
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Category is required';
      }
      return null;
    },
  );

  Widget _buildLevelField() => DropdownButtonFormField<String>(
    value: _selectedLevel,
    decoration: _inputDecoration('Difficulty Level'),
    items: _levels
        .map((level) => DropdownMenuItem(value: level, child: Text(level)))
        .toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() => _selectedLevel = value);
      }
    },
  );

  Widget _buildLanguageField() => _buildTextField(
    controller: _languageController,
    label: 'Language',
    hint: 'e.g. English',
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Language is required';
      }
      return null;
    },
  );

  Widget _buildIconField() => _buildTextField(
    controller: _iconUrlController,
    label: 'Icon URL',
    hint: 'Link to a representative image (optional)',
    keyboardType: TextInputType.url,
  );

  Widget _buildWordsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Words',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._words.asMap().entries.map(
          (entry) => _buildWordCard(entry.key, entry.value, theme),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addWord,
            icon: const Icon(Icons.add),
            label: const Text('Add another word'),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    final isEditing = widget.initialPackage != null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(isEditing ? 'Save Changes' : 'Add Package'),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final validationError = _validateWordForms();
    if (validationError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }

    setState(() => _isSubmitting = true);

    final result = PackageFormResult(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      level: _selectedLevel,
      language: _languageController.text.trim(),
      iconUrl: _iconUrlController.text.trim(),
      words: _collectWordSubmissions(),
    );

    try {
      await widget.onSubmit(result);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildWordCard(
    int wordIndex,
    _WordFormState wordForm,
    ThemeData theme,
  ) {
    final isRemovable = _words.length > 1;
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
                  'Word ${wordIndex + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isRemovable)
                  IconButton(
                    tooltip: 'Remove word',
                    onPressed: () => _removeWord(wordIndex),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
              ],
            ),
            TextFormField(
              controller: wordForm.wordController,
              decoration: _inputDecoration(
                'Word',
                hint: 'e.g. Vocabulary term',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Word text is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildDefinitionsSection(wordIndex, wordForm, theme),
            const SizedBox(height: 12),
            _buildSentencesSection(wordIndex, wordForm, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionsSection(
    int wordIndex,
    _WordFormState wordForm,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          onPressed: () =>
                              _removeDefinition(wordIndex, entry.key),
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
            onPressed: () => _addDefinition(wordIndex),
            icon: const Icon(Icons.add),
            label: const Text('Add definition'),
          ),
        ),
      ],
    );
  }

  Widget _buildSentencesSection(
    int wordIndex,
    _WordFormState wordForm,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sentences',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...wordForm.sentences.asMap().entries.map(
          (sentenceEntry) => _buildSentenceCard(
            wordIndex: wordIndex,
            sentenceIndex: sentenceEntry.key,
            sentenceForm: sentenceEntry.value,
            theme: theme,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => _addSentence(wordIndex),
            icon: const Icon(Icons.add),
            label: const Text('Add sentence'),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceCard({
    required int wordIndex,
    required int sentenceIndex,
    required _SentenceFormState sentenceForm,
    required ThemeData theme,
  }) {
    final isRemovable = _words[wordIndex].sentences.length > 1;
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
              if (isRemovable)
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
          ...sentenceForm.sources.asMap().entries.map(
            (sourceEntry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSourceRow(
                wordIndex: wordIndex,
                sentenceIndex: sentenceIndex,
                sourceIndex: sourceEntry.key,
                sourceForm: sourceEntry.value,
                theme: theme,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _addSource(wordIndex, sentenceIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add source'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceRow({
    required int wordIndex,
    required int sentenceIndex,
    required int sourceIndex,
    required _SourceFormState sourceForm,
    required ThemeData theme,
  }) {
    final isRemovable =
        _words[wordIndex].sentences[sentenceIndex].sources.length > 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: sourceForm.titleController,
                  decoration: _inputDecoration('Source title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
              ),
              if (isRemovable)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    tooltip: 'Remove source',
                    onPressed: () =>
                        _removeSource(wordIndex, sentenceIndex, sourceIndex),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: sourceForm.urlController,
            decoration: _inputDecoration('Source URL'),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'URL is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: sourceForm.typeController,
            decoration: _inputDecoration('Source type'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Type is required';
              }
              return null;
            },
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
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _addWord() {
    setState(() => _words.add(_WordFormState.empty()));
  }

  void _removeWord(int index) {
    if (_words.length == 1) return;
    setState(() {
      final removed = _words.removeAt(index);
      removed.dispose();
    });
  }

  void _addDefinition(int wordIndex) {
    setState(() => _words[wordIndex].definitions.add(_DefinitionFormState()));
  }

  void _removeDefinition(int wordIndex, int definitionIndex) {
    final definitions = _words[wordIndex].definitions;
    if (definitions.length == 1) return;
    setState(() {
      final removed = definitions.removeAt(definitionIndex);
      removed.dispose();
    });
  }

  void _addSentence(int wordIndex) {
    setState(() => _words[wordIndex].sentences.add(_SentenceFormState()));
  }

  void _removeSentence(int wordIndex, int sentenceIndex) {
    final sentences = _words[wordIndex].sentences;
    if (sentences.length == 1) return;
    setState(() {
      final removed = sentences.removeAt(sentenceIndex);
      removed.dispose();
    });
  }

  void _addSource(int wordIndex, int sentenceIndex) {
    setState(
      () => _words[wordIndex].sentences[sentenceIndex].sources.add(
        _SourceFormState(),
      ),
    );
  }

  void _removeSource(int wordIndex, int sentenceIndex, int sourceIndex) {
    final sources = _words[wordIndex].sentences[sentenceIndex].sources;
    if (sources.length == 1) return;
    setState(() {
      final removed = sources.removeAt(sourceIndex);
      removed.dispose();
    });
  }

  String? _validateWordForms() {
    if (_words.isEmpty) {
      return 'Please add at least one word.';
    }

    for (var wordIndex = 0; wordIndex < _words.length; wordIndex++) {
      final word = _words[wordIndex];
      if (word.wordController.text.trim().isEmpty) {
        return 'Word ${wordIndex + 1} requires text.';
      }

      if (word.definitions.isEmpty) {
        return 'Word ${wordIndex + 1} requires at least one definition.';
      }

      for (var defIndex = 0; defIndex < word.definitions.length; defIndex++) {
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

      for (
        var sentenceIndex = 0;
        sentenceIndex < word.sentences.length;
        sentenceIndex++
      ) {
        final sentence = word.sentences[sentenceIndex];
        if (sentence.textController.text.trim().isEmpty) {
          return 'Sentence ${sentenceIndex + 1} for word ${wordIndex + 1} requires text.';
        }

        if (sentence.sources.isEmpty) {
          return 'Sentence ${sentenceIndex + 1} for word ${wordIndex + 1} requires at least one source.';
        }

        for (
          var sourceIndex = 0;
          sourceIndex < sentence.sources.length;
          sourceIndex++
        ) {
          final source = sentence.sources[sourceIndex];
          if (source.titleController.text.trim().isEmpty) {
            return 'Source ${sourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a title.';
          }
          if (source.urlController.text.trim().isEmpty) {
            return 'Source ${sourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a URL.';
          }
          if (source.typeController.text.trim().isEmpty) {
            return 'Source ${sourceIndex + 1} for sentence ${sentenceIndex + 1} (word ${wordIndex + 1}) requires a type.';
          }
        }
      }
    }

    return null;
  }

  List<PackageFormWordSubmission> _collectWordSubmissions() {
    return _words.map((word) {
      final definitions = word.definitions
          .map(
            (definition) => PackageFormDefinitionSubmission(
              text: definition.textController.text.trim(),
              source: definition.sourceController.text.trim(),
            ),
          )
          .toList();

      final sentences = word.sentences.map((sentence) {
        final sources = sentence.sources
            .map(
              (source) => PackageFormSourceSubmission(
                title: source.titleController.text.trim(),
                url: source.urlController.text.trim(),
                type: source.typeController.text.trim(),
              ),
            )
            .toList();

        return PackageFormSentenceSubmission(
          text: sentence.textController.text.trim(),
          sources: sources,
        );
      }).toList();

      return PackageFormWordSubmission(
        text: word.wordController.text.trim(),
        definitions: definitions,
        sentences: sentences,
      );
    }).toList();
  }
}

class _WordFormState {
  _WordFormState({
    required this.wordController,
    required this.definitions,
    required this.sentences,
  });

  factory _WordFormState.empty() {
    return _WordFormState(
      wordController: TextEditingController(),
      definitions: [_DefinitionFormState()],
      sentences: [_SentenceFormState()],
    );
  }

  factory _WordFormState.fromInitial(PackageFormWordData data) {
    final definitions = data.definitions.isNotEmpty
        ? data.definitions
              .map((definition) => _DefinitionFormState.fromInitial(definition))
              .toList()
        : [_DefinitionFormState()];
    final sentences = data.sentences.isNotEmpty
        ? data.sentences
              .map((sentence) => _SentenceFormState.fromInitial(sentence))
              .toList()
        : [_SentenceFormState()];

    return _WordFormState(
      wordController: TextEditingController(text: data.text),
      definitions: definitions,
      sentences: sentences,
    );
  }

  final TextEditingController wordController;
  final List<_DefinitionFormState> definitions;
  final List<_SentenceFormState> sentences;

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

class _DefinitionFormState {
  _DefinitionFormState({
    TextEditingController? textController,
    TextEditingController? sourceController,
  }) : textController = textController ?? TextEditingController(),
       sourceController = sourceController ?? TextEditingController();

  factory _DefinitionFormState.fromInitial(PackageFormDefinitionData data) {
    return _DefinitionFormState(
      textController: TextEditingController(text: data.text),
      sourceController: TextEditingController(text: data.source),
    );
  }

  final TextEditingController textController;
  final TextEditingController sourceController;

  void dispose() {
    textController.dispose();
    sourceController.dispose();
  }
}

class _SentenceFormState {
  _SentenceFormState({
    TextEditingController? textController,
    List<_SourceFormState>? sources,
  }) : textController = textController ?? TextEditingController(),
       sources = sources ?? [_SourceFormState()];

  factory _SentenceFormState.fromInitial(PackageFormSentenceData data) {
    final sourceStates = data.sources.isNotEmpty
        ? data.sources
              .map((source) => _SourceFormState.fromInitial(source))
              .toList()
        : [_SourceFormState()];

    return _SentenceFormState(
      textController: TextEditingController(text: data.text),
      sources: sourceStates,
    );
  }

  final TextEditingController textController;
  final List<_SourceFormState> sources;

  void dispose() {
    textController.dispose();
    for (final source in sources) {
      source.dispose();
    }
  }
}

class _SourceFormState {
  _SourceFormState({
    TextEditingController? titleController,
    TextEditingController? urlController,
    TextEditingController? typeController,
  }) : titleController = titleController ?? TextEditingController(),
       urlController = urlController ?? TextEditingController(),
       typeController = typeController ?? TextEditingController();

  factory _SourceFormState.fromInitial(PackageFormSourceData data) {
    return _SourceFormState(
      titleController: TextEditingController(text: data.title),
      urlController: TextEditingController(text: data.url),
      typeController: TextEditingController(text: data.type),
    );
  }

  final TextEditingController titleController;
  final TextEditingController urlController;
  final TextEditingController typeController;

  void dispose() {
    titleController.dispose();
    urlController.dispose();
    typeController.dispose();
  }
}
