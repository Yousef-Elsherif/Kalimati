import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:kalimaiti_app/core/data/floor/user_entity.dart';
import 'package:kalimaiti_app/core/data/floor/package_entity.dart';
import 'package:kalimaiti_app/core/data/floor/word_entity.dart';
import 'package:kalimaiti_app/core/data/floor/definition_entity.dart';
import 'package:kalimaiti_app/core/data/floor/sentence_entity.dart';
import 'package:kalimaiti_app/core/data/floor/resource_entity.dart';
import 'package:kalimaiti_app/core/data/floor/daos.dart';

part 'app_database.g.dart';

@Database(
  version: 1,
  entities: [
    UserEntity,
    PackageEntity,
    WordEntity,
    DefinitionEntity,
    SentenceEntity,
    ResourceEntity,
  ],
)
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  PackageDao get packageDao;
  WordDao get wordDao;
  DefinitionDao get definitionDao;
  SentenceDao get sentenceDao;
  ResourceDao get resourceDao;
}
