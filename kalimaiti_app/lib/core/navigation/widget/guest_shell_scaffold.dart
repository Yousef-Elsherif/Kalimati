import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const GuestShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0
              ? 'Unscrambled sentences'
              : currentIndex == 1
              ? 'Flash Cards'
              : 'Match Pairs',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/unscrambledSentences');
              break;
            case 1:
              context.go('/flashCards');
              break;
            case 2:
              context.go('/matchPairs');
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
