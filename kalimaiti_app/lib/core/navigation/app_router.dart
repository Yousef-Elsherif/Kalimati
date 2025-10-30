import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/core/navigation/widget/guest_shell_scaffold.dart';
import 'package:kalimaiti_app/core/navigation/widget/shell_scaffold.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/login_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/add_package_screen.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/edit_package_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/unscrumble_sentences.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/word_listing.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/mypackages_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/packages_screen.dart';

final router = GoRouter(
  initialLocation: '/learningPackages',
  routes: [
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.matchedLocation;
        int currentIndex;
        if (location == '/learningPackages') {
          currentIndex = 0;
        } else if (location == '/addPackage') {
          currentIndex = 1;
        } else if (location == '/myPackages') {
          currentIndex = 2;
        } else {
          currentIndex = 0;
        }

        return ShellScaffold(currentIndex: currentIndex, child: child);
      },
      routes: [
        GoRoute(
          name: 'learningPackages',
          path: '/learningPackages',
          builder: (context, state) {
            return const PackagesScreen();
          },
        ),
        GoRoute(
          name: 'addPackage',
          path: '/addPackage',
          builder: (context, state) {
            return const AddPackageScreen();
          },
        ),
        GoRoute(
          name: 'myPackages',
          path: '/myPackages',
          builder: (context, state) {
            return const MyPackagesScreen();
          },
        ),
      ],
    ),

    GoRoute(
      name: 'profile',
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      name: 'editPackage',
      path: '/editPackage/:id',
      builder: (context, state) {
        final idParam = state.pathParameters['id'];
        final id = int.tryParse(idParam ?? '');
        if (id == null) {
          return const MyPackagesScreen();
        }
        return EditPackageScreen(packageId: id);
      },
    ),
    GoRoute(path: '/packages/:id', builder: (context, state) {
      final idParam = state.pathParameters['id'];
      final id = int.tryParse(idParam ?? '');
      if (id == null) {
        return const MyPackagesScreen();
      }
      return WordListing(packageId: id);
    }),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.matchedLocation;
        int currentIndex;
        if (location == '/unscrambledSentences') {
          currentIndex = 0;
        } else if (location == '/flashCards') {
          currentIndex = 1;
        } else if (location == '/matchPairs') {
          currentIndex = 2;
        } else {
          currentIndex = 0;
        }

        return GuestShellScaffold(currentIndex: currentIndex, child: child);
      },
      routes: [
        GoRoute(
          name: 'unscrambledSentences',
          path: '/unscrambledSentences/:id',
          builder: (context, state) {
            final idParam = state.pathParameters['id'];
            final id = int.tryParse(idParam ?? '');
            if (id == null) {
              return const MyPackagesScreen();
            }
            return UnscrambledSentencesScreen(wordId: id);
          },
        ),
        // GoRoute(
        //   name: 'flashCards',
        //   path: '/flashCards',
        //   builder: (context, state) {
        //     return const FlashCardsScreen();
        //   },
        // ),
        // GoRoute(
        //   name: 'matchPairs',
        //   path: '/matchPairs',
        //   builder: (context, state) {
        //     return const MatchPairsScreen();
        //   },
        // ),
      ],
    ),
  ],
);
