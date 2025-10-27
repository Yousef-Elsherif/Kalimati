import 'package:floor/floor.dart';

@entity
class ResourceEntity {
  @primaryKey
  final int? id;

  final int sentenceId; // foreign reference to SentenceEntity.id
  final String title;
  final String url;
  final String type;

  ResourceEntity({
    this.id,
    required this.sentenceId,
    required this.title,
    required this.url,
    required this.type,
  });
}
