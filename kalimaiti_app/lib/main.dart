import 'package:flutter/material.dart';
import 'features/packages/screens/packages_screen.dart';
import 'core/services/database_seeder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seed database on first run
  await DatabaseSeederService.seedDatabase();

  runApp(const MyApp());
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
