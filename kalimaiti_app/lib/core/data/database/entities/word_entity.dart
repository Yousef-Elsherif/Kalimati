import 'package:floor/floor.dart';

@entity
class WordEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final int packageId; // foreign key to PackageEntity.id
  final String text;

  WordEntity({this.id, required this.packageId, required this.text});
}
