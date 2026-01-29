import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final String location;

  const GuestShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final segments = Uri.tryParse(location)?.pathSegments ?? const [];
    final inferredPackageId = segments.length >= 2 ? segments[1] : null;
    final canGoBack = inferredPackageId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/learningPackages'),
              )
            : null,
        title: Text(
          switch (currentIndex) {
            0 => 'Unscramble Sentences',
            1 => 'Flash Cards',
            2 => 'Match Pairs',
            _ => 'Learning Games',
          },
        ),
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: (index) {
          final inferredId = inferredPackageId;
          switch (index) {
            case 0:
              if (inferredId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Choose a package first to play this mode.'),
                  ),
                );
                return;
              }
              context.go('/unscrambledSentences/$inferredId');
              break;
            case 1:
              if (inferredId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Select a package to review flash cards.'),
                  ),
                );
                return;
              }
              context.go('/flashCards/$inferredId');
              break;
            case 2:
              if (inferredId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Select a package to start the matching game.'),
                  ),
                );
                return;
              }
              context.go('/matchPairs/$inferredId');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sort_by_alpha_outlined),
            label: 'unscrambled Sentences',
            activeIcon: Icon(Icons.sort_by_alpha),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            label: 'flash Cards',
            activeIcon: Icon(Icons.style),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows_outlined),
            label: 'Match Pairs',
            activeIcon: Icon(Icons.compare_arrows),
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
