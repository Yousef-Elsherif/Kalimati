import 'package:go_router/go_router.dart';
import 'package:kalimaiti_app/core/navigation/widget/shell_scaffold.dart';
import 'package:kalimaiti_app/features/auth/presentation/screens/login_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/add_package_screen.dart';
import 'package:kalimaiti_app/features/packages/presentation/screens/edit_package_screen.dart';
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
        } else if (location == '/myPackages' ||
            location.startsWith('/editPackage')) {
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
      ],
    ),
  ],
);
