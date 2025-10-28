import 'package:floor/floor.dart';

@entity
class PackageEntity {
  @primaryKey
  final int? id;

  final String packageRemoteId; // original packageId (e.g. p1)
  final String author;
  final String category;
  final String description;
  final String iconUrl;
  final String language;
  final String lastUpdatedDate;
  final String level;
  final String title;
  final int version;

  PackageEntity({
    this.id,
    required this.packageRemoteId,
    required this.author,
    required this.category,
    required this.description,
    required this.iconUrl,
    required this.language,
    required this.lastUpdatedDate,
    required this.level,
    required this.title,
    required this.version,
  });
}
