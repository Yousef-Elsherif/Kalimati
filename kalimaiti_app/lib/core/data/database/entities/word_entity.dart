import 'package:floor/floor.dart';

@entity
class WordEntity {
  @primaryKey
  final int? id;

  final String packageRemoteId; // points to PackageEntity.packageRemoteId
  final String text;

  WordEntity({this.id, required this.packageRemoteId, required this.text});
}
