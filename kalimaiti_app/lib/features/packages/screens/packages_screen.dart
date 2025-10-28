import 'package:flutter/material.dart';
import '../../../core/data/repositories/package_repository.dart';
import '../../../core/data/database/entities/package_entity.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _packageRepo = PackageRepository();
  List<PackageEntity> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    await _packageRepo.init();
    final packages = await _packageRepo.getAllPackages();
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Packages'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _packages.isEmpty
          ? const Center(
              child: Text('No packages found. Run seed_database.dart first.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final package = _packages[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getLevelColor(package.level),
                      child: Text(
                        package.level[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      package.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(package.description),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildChip(package.category, Colors.blue),
                            const SizedBox(width: 8),
                            _buildChip(
                              package.level,
                              _getLevelColor(package.level),
                            ),
                            const SizedBox(width: 8),
                            _buildChip(package.language, Colors.green),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to package details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${package.title}')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
