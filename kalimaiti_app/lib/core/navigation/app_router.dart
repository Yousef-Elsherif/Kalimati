import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/core/navigation/widget/guest_shell_scaffold.dart';
import 'package:kalimaiti_app/core/navigation/widget/shell_scaffold.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/login_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/add_package_screen.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/edit_package_screen.dart';
import 'package:kalimaiti_app/core/data/database/entities/word_entity.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/flash_card_detail_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/flash_cards_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/match_pairs_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/unscrumble_sentences_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/games/unscrumble_sentences_game_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/mypackages_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/packages_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
    ShellRoute(
      builder: (context, state, child) {
        final location = state.matchedLocation;
        int currentIndex;
        if (location.startsWith('/flashCards')) {
          currentIndex = 1;
        } else if (location.startsWith('/unscrambledSentences')) {
          currentIndex = 0;
        } else if (location.startsWith('/matchPairs')) {
          currentIndex = 2;
        } else {
          currentIndex = 0;
        }

        return GuestShellScaffold(
          currentIndex: currentIndex,
          location: state.uri.toString(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          name: 'flashCards',
          path: '/flashCards/:packageId',
          builder: (context, state) {
            final idParam = state.pathParameters['packageId'];
            final id = int.tryParse(idParam ?? '');
            if (id == null) {
              return const MyPackagesScreen();
            }
            return FlashCardsScreen(packageId: id);
          },
          routes: [
            GoRoute(
              name: 'flashCardDetail',
              path: 'word/:wordId',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final extra = state.extra;
                if (extra is! WordEntity) {
                  return const MyPackagesScreen();
                }
                return FlashCardDetailScreen(word: extra);
              },
            ),
          ],
        ),
        GoRoute(
          name: 'unscrambledSentences',
          path: '/unscrambledSentences/:packageId',
          builder: (context, state) {
            final idParam = state.pathParameters['packageId'];
            final id = int.tryParse(idParam ?? '');
            if (id == null) {
              return const MyPackagesScreen();
            }
            return UnscrambledSentencesScreen(packageId: id);
          },
        ),
        GoRoute(
          name: 'matchPairs',
          path: '/matchPairs/:packageId',
          builder: (context, state) {
            final idParam = state.pathParameters['packageId'];
            final id = int.tryParse(idParam ?? '');
            if (id == null) {
              return const MyPackagesScreen();
            }
            return MatchPairsScreen(packageId: id);
          },
        ),
      ],
    ),
    GoRoute(
      name: 'unscrambledSentencesPlay',
      path: '/unscrambledSentences/:packageId/play/:wordId',
      builder: (context, state) {
        final packageParam = state.pathParameters['packageId'];
        final packageId = int.tryParse(packageParam ?? '');
        final wordParam = state.pathParameters['wordId'];
        final wordId = int.tryParse(wordParam ?? '');
        if (packageId == null || wordId == null) {
          return const MyPackagesScreen();
        }
        return UnscrambledSentencesGameScreen(
          packageId: packageId,
          wordId: wordId,
        );
      },
    ),
  ],
);
