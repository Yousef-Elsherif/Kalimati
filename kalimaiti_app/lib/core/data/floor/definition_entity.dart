import 'package:floor/floor.dart';

@entity
class DefinitionEntity {
  @primaryKey
  final int? id;

  final int wordId; // foreign reference to WordEntity.id
  final String text;
  final String source;

  DefinitionEntity({
    this.id,
    required this.wordId,
    required this.text,
    required this.source,
  });
}
