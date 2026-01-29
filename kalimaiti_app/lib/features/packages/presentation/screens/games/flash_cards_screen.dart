import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/features/packages/presentation/providers/games_providers.dart';
import 'package:kalimaiti_app/features/packages/presentation/widgets/word_cards_list.dart';

class FlashCardsScreen extends ConsumerWidget {
  const FlashCardsScreen({super.key, required this.packageId});

  final int packageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(packageWordsProvider(packageId));
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: wordsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(theme, error.toString()),
          data: (words) {
            if (words.isEmpty) {
              return _buildEmpty(theme);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review the words in this package.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a card to flip it and see definitions.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: WordCardsList(
                    words: words,
                    tapHint: 'Tap to view definitions.',
                    onWordSelected: (word) {
                      final wordId = word.id;
                      if (wordId == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Definition unavailable for this word.',
                              ),
                            ),
                          );
                        }
                        return;
                      }

                      context.pushNamed(
                        'flashCardDetail',
                        pathParameters: {
                          'packageId': packageId.toString(),
                          'wordId': wordId.toString(),
                        },
                        extra: word,
                      );
                    },
                  ),
                ),
              ],
            );
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
            'We couldn\'t load the flash cards.',
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

  Widget _buildEmpty(ThemeData theme) {
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
          Text('No words available yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Add words to this package to review them as flash cards.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
