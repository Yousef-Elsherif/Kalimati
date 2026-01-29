import 'package:floor/floor.dart';

@entity
class PackageEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

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

  PackageEntity copyWith({
    int? id,
    String? author,
    String? category,
    String? description,
    String? iconUrl,
    String? language,
    String? lastUpdatedDate,
    String? level,
    String? title,
    int? version,
  }) {
    return PackageEntity(
      id: id ?? this.id,
      author: author ?? this.author,
      category: category ?? this.category,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      language: language ?? this.language,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      level: level ?? this.level,
      title: title ?? this.title,
      version: version ?? this.version,
    );
  }
}
