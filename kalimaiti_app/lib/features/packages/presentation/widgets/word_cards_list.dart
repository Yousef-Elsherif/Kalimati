import 'package:flutter/material.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';

class WordCardsList extends StatelessWidget {
  const WordCardsList({
    super.key,
    required this.words,
    required this.onWordSelected,
    this.emptyMessage = 'This package does not have any words yet.',
    this.tapHint = 'Tap to explore this word.',
    this.showIndices = true,
    this.selectedWordId,
  });

  final List<WordEntity> words;
  final ValueChanged<WordEntity> onWordSelected;
  final String emptyMessage;
  final String tapHint;
  final bool showIndices;
  final int? selectedWordId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final guidanceColor =
        (theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurface)
            .withOpacity(0.7);

    if (words.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: words.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = words[index];
        final badgeLabel = (index + 1).toString().padLeft(2, '0');

        final isSelected =
            selectedWordId != null &&
            word.id != null &&
            word.id == selectedWordId;
        final basePrimary = theme.colorScheme.primary;
        final gradientColors = isSelected
            ? [
                basePrimary.withOpacity(0.22),
                theme.colorScheme.primaryContainer.withOpacity(0.18),
              ]
            : [
                theme.colorScheme.primary.withOpacity(0.14),
                theme.colorScheme.primaryContainer.withOpacity(0.10),
              ];
        final borderColor = isSelected
            ? basePrimary
            : theme.colorScheme.primary.withOpacity(0.16);

        return Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onWordSelected(word),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                border: Border.all(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showIndices)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          badgeLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (showIndices) const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            word.text,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tapHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: guidanceColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
