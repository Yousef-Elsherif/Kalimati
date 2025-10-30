import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'entities/user_entity.dart';
import 'entities/package_entity.dart';
import 'entities/word_entity.dart';
import 'entities/definition_entity.dart';
import 'entities/sentence_entity.dart';
import 'entities/resource_entity.dart';

import 'dao/user_dao.dart';
import 'dao/package_dao.dart';
import 'dao/word_dao.dart';
import 'dao/definition_dao.dart';
import 'dao/sentence_dao.dart';
import 'dao/resource_dao.dart';

part 'app_database.g.dart';

@Database(
  version: 2,
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
