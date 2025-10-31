import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/core/data/database/entities/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';
import 'package:kalimaiti_app/features/packages/presentation/providers/games_providers.dart';

class UnscrambledSentencesGameScreen extends ConsumerStatefulWidget {
  const UnscrambledSentencesGameScreen({
    super.key,
    required this.packageId,
    required this.wordId,
  });

  final int packageId;
  final int wordId;

  @override
  ConsumerState<UnscrambledSentencesGameScreen> createState() =>
      _UnscrambledSentencesGameScreenState();
}

class _UnscrambledSentencesGameScreenState
    extends ConsumerState<UnscrambledSentencesGameScreen> {
  final Random _random = Random();
  final List<_SentenceRound> _rounds = [];
  List<SentenceEntity> _sourceSentences = const [];
  String? _signature;
  int _currentRoundIndex = 0;
  int _score = 0;
  String? _feedbackMessage;
  bool _feedbackPositive = false;
  bool _gameCompleted = false;
  bool _transitionPending = false;
  bool _initialized = false;
  int _tokenIdCounter = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wordsAsync = ref.watch(packageWordsProvider(widget.packageId));

    return wordsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load words for this package.\n$error',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      ),
      data: (words) {
        WordEntity? activeWord;
        for (final candidate in words) {
          if (candidate.id == widget.wordId) {
            activeWord = candidate;
            break;
          }
        }

        if (activeWord == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We can\'t find that word in this package.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => context.go(
                        '/unscrambledSentences/${widget.packageId}',
                      ),
                      child: const Text('Pick another word'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final word = activeWord;

        final sentencesAsync = ref.watch(wordSentencesProvider(widget.wordId));

        return Scaffold(
          appBar: AppBar(
            title: Text(word.text),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: sentencesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(theme, error.toString()),
              data: (sentences) {
                if (sentences.isEmpty) {
                  return _buildEmptyState(theme, wordLabel: word.text);
                }

                final signature = _buildSignature(widget.wordId, sentences);
                if (!_initialized || signature != _signature) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _initializeRounds(sentences, signature);
                    });
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                if (_gameCompleted) {
                  return _buildSummary(theme, word.text);
                }

                if (_rounds.isEmpty) {
                  return _buildEmptyState(theme, wordLabel: word.text);
                }

                final round = _rounds[_currentRoundIndex];
                return _buildGameView(theme, round, word.text);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'We couldn\'t load the sentences.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, {String? wordLabel}) {
    final title = wordLabel == null
        ? 'No practice sentences yet'
        : 'No sentences for "$wordLabel" yet';
    final subtitle = wordLabel == null
        ? 'Once sentences are added for this word, you can practice here.'
        : 'Add sentences to this word to unlock the activity.';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(
    ThemeData theme,
    _SentenceRound round,
    String wordLabel,
  ) {
    final totalRounds = _rounds.length;
    final completedRounds = _rounds
        .where((element) => element.isCompleted)
        .length;
    final progressValue = totalRounds == 0
        ? 0.0
        : completedRounds / totalRounds;
    final attemptsLeft = max(0, 3 - round.attempts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Practicing "$wordLabel"',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Chip(
              label: Text('Sentence ${_currentRoundIndex + 1} / $totalRounds'),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text('Score $_score / $totalRounds'),
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.12),
              labelStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const Spacer(),
            Text(
              'Attempts left: $attemptsLeft',
              style: theme.textTheme.bodySmall?.copyWith(
                color: attemptsLeft > 0
                    ? theme.colorScheme.onSurface.withOpacity(0.7)
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        if (_feedbackMessage != null) ...[
          const SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              color: _feedbackPositive
                  ? theme.colorScheme.primary.withOpacity(0.12)
                  : theme.colorScheme.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _feedbackPositive
                        ? Icons.emoji_emotions_outlined
                        : Icons.lightbulb_outline,
                    color: _feedbackPositive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _feedbackMessage ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _feedbackPositive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Arrange the words to form a meaningful sentence.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSelectedSentence(theme, round),
                const SizedBox(height: 24),
                Text(
                  'Word bank',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildWordBank(theme, round),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildActionRow(theme, round),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSelectedSentence(ThemeData theme, _SentenceRound round) {
    if (round.selectedTokens.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
            width: 1.2,
          ),
          color: theme.colorScheme.primary.withOpacity(0.04),
        ),
        child: Text(
          'Tap words below to build the sentence.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1.2,
        ),
        color: theme.colorScheme.primary.withOpacity(0.04),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: round.selectedTokens
            .map(
              (token) => InputChip(
                label: Text(token.text),
                onDeleted: round.isCompleted
                    ? null
                    : () => _removeSelectedToken(round, token),
                deleteIcon: round.isCompleted ? null : const Icon(Icons.close),
                labelStyle: theme.textTheme.bodyMedium,
                backgroundColor: theme.colorScheme.surface,
                disabledColor: theme.colorScheme.surface,
                side: BorderSide(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildWordBank(ThemeData theme, _SentenceRound round) {
    if (round.availableTokens.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant),
          color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        ),
        child: Text(
          round.isCompleted
              ? 'Sentence completed! Moving on...'
              : 'All words are in use.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: round.availableTokens
            .map(
              (token) => ActionChip(
                label: Text(token.text),
                onPressed: round.isCompleted
                    ? null
                    : () => _selectToken(round, token),
                labelStyle: theme.textTheme.bodyMedium,
                backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                  0.6,
                ),
                disabledColor: theme.colorScheme.surfaceVariant.withOpacity(
                  0.6,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionRow(ThemeData theme, _SentenceRound round) {
    if (round.awaitingAdvance) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _advanceAfterReveal(round),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Continue'),
        ),
      );
    }

    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: round.isCompleted || round.selectedTokens.isEmpty
              ? null
              : () {
                  setState(() {
                    round.resetSelection();
                    _feedbackMessage = null;
                  });
                },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _canSubmit(round) ? () => _submit(round) : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Submit'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme, String wordLabel) {
    final totalSentences = _rounds.length;

    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Great work on "$wordLabel"!',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You completed $totalSentences sentence(s).',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Score: $_score / $totalSentences',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => _restartGame(),
                icon: const Icon(Icons.replay),
                label: const Text('Play again'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () =>
                    context.go('/unscrambledSentences/${widget.packageId}'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Choose another word'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeRounds(List<SentenceEntity> sentences, String signature) {
    _sourceSentences = sentences;
    _signature = signature;
    _rounds
      ..clear()
      ..addAll([for (final sentence in sentences) _createRound(sentence)]);
    _currentRoundIndex = 0;
    _score = 0;
    _feedbackMessage = null;
    _feedbackPositive = false;
    _gameCompleted = false;
    _transitionPending = false;
    _initialized = true;
  }

  _SentenceRound _createRound(SentenceEntity sentence) {
    final tokens = _tokenize(sentence.text);
    final pieces = [
      for (var i = 0; i < tokens.length; i++)
        _WordPiece(
          id: '${sentence.id ?? sentence.hashCode}-${_tokenIdCounter++}',
          text: tokens[i],
        ),
    ];
    final scrambled = _scramblePieces(pieces);
    return _SentenceRound(
      sentence: sentence,
      correctOrder: pieces,
      shuffledTokens: scrambled,
    );
  }

  List<String> _tokenize(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((chunk) => chunk.trim().isNotEmpty)
        .toList();
  }

  List<_WordPiece> _scramblePieces(List<_WordPiece> original) {
    if (original.length <= 1) {
      return [...original];
    }

    final scrambled = [...original];
    do {
      scrambled.shuffle(_random);
    } while (_listsMatch(scrambled, original));
    return scrambled;
  }

  bool _listsMatch(List<_WordPiece> a, List<_WordPiece> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id == b[i].id) continue;
      if (_normalizeToken(a[i].text) != _normalizeToken(b[i].text)) {
        return false;
      }
    }
    return true;
  }

  String _normalizeToken(String token) {
    return token.trim().toLowerCase();
  }

  bool _canSubmit(_SentenceRound round) {
    if (round.isCompleted) return false;
    if (round.selectedTokens.isEmpty) return false;
    return true;
  }

  void _selectToken(_SentenceRound round, _WordPiece token) {
    if (round.isCompleted) return;
    setState(() {
      round.availableTokens.remove(token);
      round.selectedTokens.add(token);
      _feedbackMessage = null;
    });
  }

  void _removeSelectedToken(_SentenceRound round, _WordPiece token) {
    if (round.isCompleted) return;
    setState(() {
      round.selectedTokens.remove(token);
      round.availableTokens.add(token);
      _feedbackMessage = null;
    });
  }

  void _submit(_SentenceRound round) {
    if (round.isCompleted) return;

    if (round.selectedTokens.length != round.correctOrder.length) {
      setState(() {
        _feedbackMessage = 'Use all the words to rebuild the sentence.';
        _feedbackPositive = false;
      });
      return;
    }

    if (_listsMatch(round.selectedTokens, round.correctOrder)) {
      setState(() {
        round.isCompleted = true;
        _score += 1;
        _feedbackMessage = 'Great job! That sentence is correct.';
        _feedbackPositive = true;
      });
      _scheduleNextRound();
      return;
    }

    setState(() {
      round.attempts += 1;
      if (round.attempts >= 3) {
        round.isCompleted = true;
        round.isRevealed = true;
        round.selectedTokens = [...round.correctOrder];
        round.availableTokens.clear();
        round.awaitingAdvance = true;
        _feedbackMessage =
            'Here\'s the correct answer. Tap continue when you\'re ready.';
        _feedbackPositive = false;
      } else {
        _feedbackMessage = 'Not quite. Rearrange and try again.';
        _feedbackPositive = false;
      }
    });

    if (round.awaitingAdvance) {
      return;
    }
  }

  void _scheduleNextRound() {
    if (_transitionPending) return;
    _transitionPending = true;
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _transitionPending = false;
      _goToNextRound();
    });
  }

  void _advanceAfterReveal(_SentenceRound round) {
    if (!round.awaitingAdvance) return;
    setState(() {
      round.awaitingAdvance = false;
    });
    _goToNextRound();
  }

  void _goToNextRound() {
    if (_currentRoundIndex + 1 < _rounds.length) {
      setState(() {
        _currentRoundIndex += 1;
        _feedbackMessage = null;
        _feedbackPositive = false;
      });
    } else {
      setState(() {
        _gameCompleted = true;
      });
    }
  }

  void _restartGame() {
    if (_sourceSentences.isEmpty || _signature == null) return;
    setState(() {
      _initializeRounds(_sourceSentences, _signature!);
    });
  }

  String _buildSignature(int? wordId, List<SentenceEntity> sentences) {
    final prefix = wordId?.toString() ?? 'unknown';
    final sentencesKey = sentences
        .map((s) => '${s.id ?? s.text}-${s.text.hashCode}')
        .join('|');
    return '$prefix::$sentencesKey';
  }
}

class _SentenceRound {
  _SentenceRound({
    required this.sentence,
    required this.correctOrder,
    required List<_WordPiece> shuffledTokens,
  }) : shuffledTokens = List.unmodifiable(shuffledTokens),
       availableTokens = [...shuffledTokens],
       selectedTokens = [];

  final SentenceEntity sentence;
  final List<_WordPiece> correctOrder;
  final List<_WordPiece> shuffledTokens;
  List<_WordPiece> availableTokens;
  List<_WordPiece> selectedTokens;
  int attempts = 0;
  bool isCompleted = false;
  bool isRevealed = false;
  bool awaitingAdvance = false;

  void resetSelection() {
    availableTokens = [...shuffledTokens];
    selectedTokens = [];
    awaitingAdvance = false;
  }
}

class _WordPiece {
  const _WordPiece({required this.id, required this.text});

  final String id;
  final String text;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _WordPiece && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
