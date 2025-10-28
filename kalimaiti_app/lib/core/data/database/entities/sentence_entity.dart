import 'package:floor/floor.dart';

@entity
class SentenceEntity {
  @primaryKey
  final int? id;

  final int wordId; // foreign reference to WordEntity.id
  final String text;

  SentenceEntity({this.id, required this.wordId, required this.text});
}
