import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/packages/screens/packages_screen.dart';
import 'core/data/database/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure DB is opened and seeded before app starts. The provider caches
  // the opened DB instance so the Riverpod provider will reuse it.
  await openAndSeedDatabase();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalimati Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PackagesScreen(),
    );
  }
}
