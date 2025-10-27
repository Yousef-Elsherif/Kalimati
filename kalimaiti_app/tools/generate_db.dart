import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final repoRoot = Directory.current.path;
  final usersPath = args.isNotEmpty ? args[0] : '$repoRoot/users.json';
  final packagesPath = args.length > 1
      ? args[1]
      : '$repoRoot/lib/assets/packages.json';
  final outPath = args.length > 2
      ? args[2]
      : '$repoRoot/lib/assets/data/db.json';

  final usersFile = File(usersPath);
  final packagesFile = File(packagesPath);
  final outFile = File(outPath);

  if (!await usersFile.exists()) {
    stderr.writeln('Users file not found: $usersPath');
    exit(2);
  }
  if (!await packagesFile.exists()) {
    stderr.writeln('Packages file not found: $packagesPath');
    exit(2);
  }

  final users = jsonDecode(await usersFile.readAsString());
  final packages = jsonDecode(await packagesFile.readAsString());

  final db = {'users': users, 'packages': packages};

  await outFile.create(recursive: true);
  await outFile.writeAsString(JsonEncoder.withIndent('  ').convert(db));

  print('Aggregated DB written to: ${outFile.path}');
}
