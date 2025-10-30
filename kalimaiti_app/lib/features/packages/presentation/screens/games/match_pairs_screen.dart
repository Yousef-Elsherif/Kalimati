import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalimaiti_app/features/packages/presentation/providers/games_providers.dart';

class MatchPairsScreen extends ConsumerStatefulWidget {
  const MatchPairsScreen({super.key, required this.packageId});

  final int packageId;

  @override
  ConsumerState<MatchPairsScreen> createState() => _MatchPairsScreenState();
}

class _MatchPairsScreenState extends ConsumerState<MatchPairsScreen> {
  final Random _random = Random();

  String? _signature;
  bool _initialized = false;

  List<_MatchCard> _cards = const [];
  final Set<String> _matchedCardIds = {};
  final Set<String> _matchedPairKeys = {};
  List<_MatchCard> _selectedCards = [];
  bool _isProcessing = false;
  int _attempts = 0;
  int _score = 0;
  String? _feedbackMessage;
  bool _feedbackPositive = false;

  @override
  Widget build(BuildContext context) {
    final pairsAsync =
        ref.watch(packageWordDefinitionPairsProvider(widget.packageId));
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: pairsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(theme, error.toString()),
          data: (pairs) {
            if (pairs.isEmpty) {
              return _buildEmpty(theme);
            }

            final signature = _buildSignature(pairs);
            if (!_initialized || signature != _signature) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _setupGame(pairs, signature);
                });
              });
              return const Center(child: CircularProgressIndicator());
            }

            final totalPairs = pairs.length;
            if (_matchedPairKeys.length == totalPairs) {
              return _buildSummary(theme, totalPairs);
            }

            return _buildGame(theme, pairs);
          },
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'We couldn\'t load the pairs.',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.extension_off_outlined,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No pairs available yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add definitions to this package to unlock the matching game.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGame(ThemeData theme, List<WordDefinitionPair> pairs) {
    final totalPairs = pairs.length;
    final progressValue =
        totalPairs == 0 ? 0.0 : _matchedPairKeys.length / totalPairs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Chip(
              label: Text(
                'Matched $_score / $totalPairs',
              ),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              labelStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text('Attempts $_attempts'),
              backgroundColor: theme.colorScheme.secondary.withOpacity(0.12),
              labelStyle: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.secondary),
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
                        ? Icons.celebration_outlined
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 2;
              if (width > 900) {
                crossAxisCount = 4;
              } else if (width > 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                itemCount: _cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final isMatched = _matchedCardIds.contains(card.id);
                  final isSelected = _selectedCards.any(
                    (element) => element.id == card.id,
                  );
                  return _MatchCardTile(
                    card: card,
                    isMatched: isMatched,
                    isSelected: isSelected,
                    onTap: () => _handleTap(card),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(ThemeData theme, int totalPairs) {
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
                'Pairs completed!',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'You matched all $totalPairs pairs.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Attempts: $_attempts',
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
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to words'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setupGame(List<WordDefinitionPair> pairs, String signature) {
    final cards = <_MatchCard>[];
    final pairKeys = <String>{};

    for (final pair in pairs) {
      final pairKey =
          '${pair.word.id ?? pair.word.text}-${pair.definition.id ?? pair.definition.text.hashCode}';
      if (pairKeys.contains(pairKey)) continue;
      pairKeys.add(pairKey);

      cards.add(
        _MatchCard(
          id: 'word-$pairKey',
          display: pair.word.text,
          pairKey: pairKey,
          type: MatchCardType.word,
        ),
      );
      cards.add(
        _MatchCard(
          id: 'definition-$pairKey',
          display: pair.definition.text,
          pairKey: pairKey,
          type: MatchCardType.definition,
        ),
      );
    }

    cards.shuffle(_random);

    _signature = signature;
    _initialized = true;
    _cards = cards;
    _matchedCardIds.clear();
    _matchedPairKeys.clear();
    _selectedCards = [];
    _isProcessing = false;
    _attempts = 0;
    _score = 0;
    _feedbackMessage = null;
    _feedbackPositive = false;
  }

  void _handleTap(_MatchCard card) {
    if (_isProcessing) return;
    if (_matchedCardIds.contains(card.id)) return;
    if (_selectedCards.any((element) => element.id == card.id)) return;

    setState(() {
      _selectedCards = [..._selectedCards, card];
    });

    if (_selectedCards.length == 2) {
      _processSelection();
    }
  }

  void _processSelection() {
    if (_selectedCards.length != 2) return;

    final first = _selectedCards[0];
    final second = _selectedCards[1];
    final isMatch =
        first.pairKey == second.pairKey && first.type != second.type;

    setState(() {
      _attempts += 1;
      _isProcessing = true;
      if (isMatch) {
        _matchedPairKeys.add(first.pairKey);
        _matchedCardIds.addAll([first.id, second.id]);
        _score = _matchedPairKeys.length;
        _feedbackMessage = 'Great match!';
        _feedbackPositive = true;
      } else {
        _feedbackMessage = 'Those don\'t match. Try again.';
        _feedbackPositive = false;
      }
    });

    Future.delayed(Duration(milliseconds: isMatch ? 600 : 850), () {
      if (!mounted) return;
      setState(() {
        _selectedCards = [];
        _isProcessing = false;
        if (_matchedPairKeys.length == _cards.length ~/ 2) {
          _feedbackMessage = null;
        }
      });
    });
  }

  void _restartGame() {
    if (_signature == null) return;
    setState(() {
      _initialized = false;
    });
  }

  String _buildSignature(List<WordDefinitionPair> pairs) {
    return pairs
        .map(
          (pair) =>
              '${pair.word.id ?? pair.word.text}-${pair.definition.id ?? pair.definition.text.hashCode}',
        )
        .join('|');
  }
}

enum MatchCardType { word, definition }

class _MatchCard {
  const _MatchCard({
    required this.id,
    required this.display,
    required this.pairKey,
    required this.type,
  });

  final String id;
  final String display;
  final String pairKey;
  final MatchCardType type;
}

class _MatchCardTile extends StatelessWidget {
  const _MatchCardTile({
    required this.card,
    required this.isMatched,
    required this.isSelected,
    required this.onTap,
  });

  final _MatchCard card;
  final bool isMatched;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = card.type == MatchCardType.word
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;
    final backgroundColor = isMatched
        ? baseColor.withOpacity(0.2)
        : isSelected
            ? baseColor.withOpacity(0.16)
            : theme.colorScheme.surface;
    final borderColor = isMatched
        ? baseColor
        : isSelected
            ? baseColor.withOpacity(0.7)
            : theme.colorScheme.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.4,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: baseColor.withOpacity(0.18),
                  offset: const Offset(0, 6),
                  blurRadius: 16,
                ),
              ]
            : const [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isMatched ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                card.type == MatchCardType.word
                    ? Icons.text_fields_outlined
                    : Icons.menu_book_outlined,
                color: baseColor,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Text(
                    card.display,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
