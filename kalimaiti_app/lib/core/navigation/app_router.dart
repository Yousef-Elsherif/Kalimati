import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/core/navigation/widget/shell_scaffold.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/login_screen.dart';
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
        int currentIndex;
        switch (state.uri.toString()) {
          case '/learningPackages':
            currentIndex = 0;
            break;
          case '/addPackage':
            currentIndex = 1;
            break;
          case '/myPackages':
            currentIndex = 2;
            break;
          default:
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
      ],
    ),
  ],
);
