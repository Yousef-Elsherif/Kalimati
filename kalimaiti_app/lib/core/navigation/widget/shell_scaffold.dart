import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/features/auth/presentation/providers/auth_provider.dart';

class ShellScaffold extends ConsumerWidget {
  final Widget child;
  final int currentIndex;

  const ShellScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAuth = authState.isAuthenticated;

    if (!isAuth) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Learning Packages'),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Login',
              color: Colors.black,
              onPressed: () {
                context.push('/login');
              },
            ),
          ],
        ),
        body: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentIndex == 0
              ? 'Home'
              : currentIndex == 1
              ? 'Learning Packages'
              : 'My Packages',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).signOut();
                        Navigator.of(context).pop();
                        context.go('/learningPackages');
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/learningPackages');
              break;
            case 2:
              context.go('/myPackages');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Learning Packages',
            activeIcon: Icon(Icons.book),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            label: 'My Packages',
            activeIcon: Icon(Icons.edit),
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
