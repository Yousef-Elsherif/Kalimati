import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:kalimaiti_app/core/data/database/entities/resource_entity.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';
import 'package:kalimaiti_app/features/packages/presentation/providers/games_providers.dart';

class FlashCardDetailScreen extends ConsumerStatefulWidget {
  const FlashCardDetailScreen({super.key, required this.word});

  final WordEntity word;

  @override
  ConsumerState<FlashCardDetailScreen> createState() =>
      _FlashCardDetailScreenState();
}

class _FlashCardDetailScreenState extends ConsumerState<FlashCardDetailScreen> {
  static const int _loopSeed = 512;
  late final PageController _pageController;
  bool _loopPrepared = false;
  int _currentRawIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _prepareLooping(int slideCount) {
    if (_loopPrepared || slideCount <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = slideCount * _loopSeed;
      _pageController.jumpToPage(target);
      setState(() {
        _currentRawIndex = target;
        _loopPrepared = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = widget.word;
    final wordId = word.id;

    if (wordId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flash Cards')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'We need a saved word before we can show its flash cards.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final bundleAsync = ref.watch(wordLearningBundleProvider(wordId));

    return Scaffold(
      appBar: AppBar(title: Text(word.text)),
      body: SafeArea(
        child: bundleAsync.when(
          data: (bundle) => _buildCardDeck(context, theme, word, bundle),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildError(theme, error),
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'We could not build the learning cards.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardDeck(
    BuildContext context,
    ThemeData theme,
    WordEntity word,
    WordLearningBundle bundle,
  ) {
    final slides = _createSlides(word, bundle);
    if (slides.isEmpty) {
      return _buildEmpty(theme);
    }

    _prepareLooping(slides.length);
    final visibleIndex = _loopPrepared
        ? _currentRawIndex % slides.length
        : math.min(_currentRawIndex, slides.length - 1);
    final progress = slides.isEmpty ? 0.0 : (visibleIndex + 1) / slides.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Swipe left or right to loop through every aspect of this word.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                avatar: const Icon(Icons.auto_stories, size: 18),
                label: Text('${slides.length} cards'),
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                avatar: const Icon(Icons.speed, size: 18),
                label: Text('Card ${visibleIndex + 1} / ${slides.length}'),
                backgroundColor: theme.colorScheme.secondary.withValues(
                  alpha: 0.12,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentRawIndex = index;
                });
              },
              itemBuilder: (context, rawIndex) {
                final slide = slides[rawIndex % slides.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double pageOffset = 0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        final page = _pageController.page ?? 0.0;
                        pageOffset = (page - rawIndex).clamp(-1.0, 1.0);
                      } else {
                        pageOffset = ((_currentRawIndex - rawIndex) * 1.0)
                            .clamp(-1.0, 1.0);
                      }
                      final rotation = pageOffset * 0.5;
                      final tilt = (1 - pageOffset.abs()).clamp(0.0, 1.0);
                      final perspective = 0.002;
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, perspective)
                          ..rotateY(rotation),
                        alignment: Alignment.center,
                        child: Opacity(opacity: tilt, child: child),
                      );
                    },
                    child: _FlashCardSlide(
                      key: ValueKey('${slide.kind}-${slide.title}'),
                      payload: slide,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
            ),
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
            Icons.lightbulb_circle,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'We need a little more content.',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add definitions, example sentences, or resources for this word to activate the flash cards.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<_SlidePayload> _createSlides(
    WordEntity word,
    WordLearningBundle bundle,
  ) {
    final slides = <_SlidePayload>[];
    final allResources = bundle.sentences
        .expand((sentence) => sentence.resources)
        .toList();

    slides.add(
      _SlidePayload(
        kind: _SlideKind.overview,
        title: word.text,
        body:
            'A quick tour of everything we know about this word. Keep swiping to loop through definitions, usage, and reference material.',
        badges: [
          _BadgeData(
            Icons.menu_book_rounded,
            '${bundle.definitions.length} definition${bundle.definitions.length == 1 ? '' : 's'}',
          ),
          _BadgeData(
            Icons.voice_chat,
            '${bundle.sentences.length} sentence${bundle.sentences.length == 1 ? '' : 's'}',
          ),
          _BadgeData(
            Icons.collections_bookmark,
            '${allResources.length} resource${allResources.length == 1 ? '' : 's'}',
          ),
        ],
      ),
    );

    for (var i = 0; i < bundle.definitions.length; i++) {
      final definition = bundle.definitions[i];
      slides.add(
        _SlidePayload(
          kind: _SlideKind.definition,
          title: 'Definition ${i + 1}',
          body: definition.text,
          caption: definition.source.isNotEmpty
              ? 'Source: ${definition.source}'
              : null,
        ),
      );
    }

    for (var i = 0; i < bundle.sentences.length; i++) {
      final sentenceBundle = bundle.sentences[i];
      slides.add(
        _SlidePayload(
          kind: _SlideKind.sentence,
          title: 'Sentence ${i + 1}',
          body: sentenceBundle.sentence.text,
          caption: sentenceBundle.resources.isNotEmpty
              ? 'Linked resources: ${sentenceBundle.resources.length}'
              : 'Visualise this sentence to lock in the context.',
          resources: sentenceBundle.resources,
        ),
      );
    }

    for (var i = 0; i < allResources.length; i++) {
      final resource = allResources[i];
      slides.add(
        _SlidePayload(
          kind: _SlideKind.resource,
          title: resource.title.isNotEmpty
              ? resource.title
              : 'Resource ${i + 1}',
          body: _formatResourceType(resource.type, resource.url),
          caption: resource.url,
          resources: [resource],
        ),
      );
    }

    return slides;
  }
}

enum _SlideKind { overview, definition, sentence, resource }

class _BadgeData {
  const _BadgeData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _SlidePayload {
  const _SlidePayload({
    required this.kind,
    required this.title,
    required this.body,
    this.caption,
    this.resources = const <ResourceEntity>[],
    this.badges = const <_BadgeData>[],
  });

  final _SlideKind kind;
  final String title;
  final String body;
  final String? caption;
  final List<ResourceEntity> resources;
  final List<_BadgeData> badges;
}

class _FlashCardSlide extends StatelessWidget {
  const _FlashCardSlide({super.key, required this.payload});

  final _SlidePayload payload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final gradient = _gradientForKind(payload.kind, colors);
    final icon = _iconForKind(payload.kind);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: colors.primary),
            const SizedBox(height: 12),
            Text(
              payload.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payload.body,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                        letterSpacing: 0.1,
                      ),
                    ),
                    if (payload.caption != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        payload.caption!,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                    if (payload.badges.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: payload.badges
                            .map(
                              (badge) => Chip(
                                avatar: Icon(
                                  badge.icon,
                                  size: 18,
                                  color: colors.onPrimaryContainer,
                                ),
                                label: Text(badge.label),
                                backgroundColor: colors.primaryContainer
                                    .withValues(alpha: 0.4),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (payload.kind == _SlideKind.sentence &&
                        payload.resources.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Resources',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: payload.resources
                            .map(
                              (resource) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ResourcePreview(
                                  resource: resource,
                                  compact: true,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    if (payload.kind == _SlideKind.resource &&
                        payload.resources.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _ResourcePreview(
                        resource: payload.resources.first,
                        compact: false,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static LinearGradient _gradientForKind(_SlideKind kind, ColorScheme colors) {
    switch (kind) {
      case _SlideKind.overview:
        return LinearGradient(
          colors: [
            colors.primary.withValues(alpha: 0.14),
            colors.secondaryContainer.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case _SlideKind.definition:
        return LinearGradient(
          colors: [
            colors.primaryContainer.withValues(alpha: 0.22),
            colors.primary.withValues(alpha: 0.18),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case _SlideKind.sentence:
        return LinearGradient(
          colors: [
            colors.tertiaryContainer.withValues(alpha: 0.20),
            colors.tertiary.withValues(alpha: 0.16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case _SlideKind.resource:
        return LinearGradient(
          colors: [
            colors.surfaceTint.withValues(alpha: 0.22),
            colors.secondary.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static IconData _iconForKind(_SlideKind kind) {
    switch (kind) {
      case _SlideKind.overview:
        return Icons.star_rate_rounded;
      case _SlideKind.definition:
        return Icons.menu_book_rounded;
      case _SlideKind.sentence:
        return Icons.record_voice_over;
      case _SlideKind.resource:
        return Icons.collections_bookmark;
    }
  }
}

class _ResourcePreview extends StatelessWidget {
  const _ResourcePreview({required this.resource, this.compact = false});

  final ResourceEntity resource;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final typeLabel = _formatResourceType(resource.type, resource.url);
    final resourceIcon = _iconForResource(resource);
    final lowerType = resource.type.toLowerCase();
    final isImage = _isImageType(lowerType, resource.url);
    final isVideo = _isVideoType(lowerType, resource.url);
    final previewHeight = compact ? 160.0 : 220.0;

    Widget? preview;
    if (isImage) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: previewHeight,
          width: double.infinity,
          child: Image.network(
            resource.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              final expected = loadingProgress.expectedTotalBytes;
              final loaded = loadingProgress.cumulativeBytesLoaded;
              final value = expected != null ? loaded / expected : null;
              return Center(child: CircularProgressIndicator(value: value));
            },
            errorBuilder: (context, error, stackTrace) => _PreviewPlaceholder(
              message: 'Image preview unavailable',
              height: previewHeight,
            ),
          ),
        ),
      );
    } else if (isVideo) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _VideoResourcePlayer(url: resource.url, compact: compact),
      );
    }

    final title = resource.title.isNotEmpty ? resource.title : typeLabel;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: compact ? 0.6 : 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.14)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(resourceIcon, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                typeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (preview != null) ...[preview, const SizedBox(height: 12)],
          Text(title, style: theme.textTheme.titleMedium),
          if (!compact || (!isImage && !isVideo)) ...[
            const SizedBox(height: 8),
            SelectableText(
              resource.url,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoResourcePlayer extends StatefulWidget {
  const _VideoResourcePlayer({required this.url, this.compact = false});

  final String url;
  final bool compact;

  @override
  State<_VideoResourcePlayer> createState() => _VideoResourcePlayerState();
}

class _VideoResourcePlayerState extends State<_VideoResourcePlayer> {
  VideoPlayerController? _controller;
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri == null || uri.scheme.isEmpty) {
      _error = 'Invalid video URL';
      _isInitializing = false;
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    controller.setLooping(true);
    controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() {
            _isInitializing = false;
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            _error = 'Video preview unavailable';
            _isInitializing = false;
          });
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.compact ? 180.0 : 220.0;
    if (_error != null) {
      return _PreviewPlaceholder(message: _error!, height: height);
    }

    final controller = _controller;
    if (controller == null ||
        _isInitializing ||
        !controller.value.isInitialized) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final aspectRatio = controller.value.aspectRatio == 0
        ? 16 / 9
        : controller.value.aspectRatio;

    return GestureDetector(
      onTap: _togglePlayback,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: aspectRatio, child: VideoPlayer(controller)),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              controller.value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_fill,
              color: Colors.white,
              size: widget.compact ? 48 : 56,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.message, required this.height});

  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.38,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

String _formatResourceType(String rawType, String url) {
  if (rawType.isEmpty) {
    return _isImageType('', url)
        ? 'Image'
        : _isVideoType('', url)
        ? 'Video'
        : 'Resource';
  }
  final lower = rawType.toLowerCase();
  if (_isImageType(lower, url)) return 'Image';
  if (_isVideoType(lower, url)) return 'Video';
  switch (lower) {
    case 'photo':
      return 'Photo';
    case 'picture':
      return 'Picture';
    case 'audio':
      return 'Audio';
    case 'article':
      return 'Article';
    default:
      return lower[0].toUpperCase() + lower.substring(1);
  }
}

IconData _iconForResource(ResourceEntity resource) {
  final type = resource.type.toLowerCase();
  if (_isVideoType(type, resource.url)) return Icons.play_circle_fill;
  if (_isImageType(type, resource.url)) return Icons.image_rounded;
  switch (type) {
    case 'photo':
    case 'picture':
      return Icons.photo_library_rounded;
    case 'audio':
      return Icons.graphic_eq;
    case 'article':
      return Icons.description;
    default:
      return Icons.link;
  }
}

bool _isImageType(String type, String url) {
  const imageHints = {'image', 'photo', 'picture', 'img', 'jpeg', 'jpg', 'png'};
  if (imageHints.contains(type)) return true;
  final extension = _safeExtension(url);
  return {'jpg', 'jpeg', 'png', 'gif', 'webp'}.contains(extension);
}

bool _isVideoType(String type, String url) {
  const videoHints = {'video', 'clip', 'mp4', 'mov', 'movie'};
  if (videoHints.contains(type)) return true;
  final extension = _safeExtension(url);
  return {'mp4', 'mov', 'm4v', 'webm'}.contains(extension);
}

String _safeExtension(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return '';
  final path = uri.path.toLowerCase();
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1) return '';
  return path.substring(lastDot + 1);
}
