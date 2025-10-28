// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  PackageDao? _packageDaoInstance;

  WordDao? _wordDaoInstance;

  DefinitionDao? _definitionDaoInstance;

  SentenceDao? _sentenceDaoInstance;

  ResourceDao? _resourceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UserEntity` (`id` INTEGER, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `email` TEXT NOT NULL, `password` TEXT NOT NULL, `photoUrl` TEXT NOT NULL, `role` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `PackageEntity` (`id` INTEGER, `packageRemoteId` TEXT NOT NULL, `author` TEXT NOT NULL, `category` TEXT NOT NULL, `description` TEXT NOT NULL, `iconUrl` TEXT NOT NULL, `language` TEXT NOT NULL, `lastUpdatedDate` TEXT NOT NULL, `level` TEXT NOT NULL, `title` TEXT NOT NULL, `version` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `WordEntity` (`id` INTEGER, `packageRemoteId` TEXT NOT NULL, `text` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DefinitionEntity` (`id` INTEGER, `wordId` INTEGER NOT NULL, `text` TEXT NOT NULL, `source` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SentenceEntity` (`id` INTEGER, `wordId` INTEGER NOT NULL, `text` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ResourceEntity` (`id` INTEGER, `sentenceId` INTEGER NOT NULL, `title` TEXT NOT NULL, `url` TEXT NOT NULL, `type` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  PackageDao get packageDao {
    return _packageDaoInstance ??= _$PackageDao(database, changeListener);
  }

  @override
  WordDao get wordDao {
    return _wordDaoInstance ??= _$WordDao(database, changeListener);
  }

  @override
  DefinitionDao get definitionDao {
    return _definitionDaoInstance ??= _$DefinitionDao(database, changeListener);
  }

  @override
  SentenceDao get sentenceDao {
    return _sentenceDaoInstance ??= _$SentenceDao(database, changeListener);
  }

  @override
  ResourceDao get resourceDao {
    return _resourceDaoInstance ??= _$ResourceDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userEntityInsertionAdapter = InsertionAdapter(
            database,
            'UserEntity',
            (UserEntity item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'email': item.email,
                  'password': item.password,
                  'photoUrl': item.photoUrl,
                  'role': item.role
                }),
        _userEntityUpdateAdapter = UpdateAdapter(
            database,
            'UserEntity',
            ['id'],
            (UserEntity item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'email': item.email,
                  'password': item.password,
                  'photoUrl': item.photoUrl,
                  'role': item.role
                }),
        _userEntityDeletionAdapter = DeletionAdapter(
            database,
            'UserEntity',
            ['id'],
            (UserEntity item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'email': item.email,
                  'password': item.password,
                  'photoUrl': item.photoUrl,
                  'role': item.role
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserEntity> _userEntityInsertionAdapter;

  final UpdateAdapter<UserEntity> _userEntityUpdateAdapter;

  final DeletionAdapter<UserEntity> _userEntityDeletionAdapter;

  @override
  Future<List<UserEntity>> findAllUsers() async {
    return _queryAdapter.queryList('SELECT * FROM UserEntity',
        mapper: (Map<String, Object?> row) => UserEntity(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            photoUrl: row['photoUrl'] as String,
            role: row['role'] as String));
  }

  @override
  Future<UserEntity?> findUserByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM UserEntity WHERE email = ?1',
        mapper: (Map<String, Object?> row) => UserEntity(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            photoUrl: row['photoUrl'] as String,
            role: row['role'] as String),
        arguments: [email]);
  }

  @override
  Future<UserEntity?> authenticate(
    String email,
    String password,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM UserEntity WHERE email = ?1 AND password = ?2',
        mapper: (Map<String, Object?> row) => UserEntity(
            id: row['id'] as int?,
            firstName: row['firstName'] as String,
            lastName: row['lastName'] as String,
            email: row['email'] as String,
            password: row['password'] as String,
            photoUrl: row['photoUrl'] as String,
            role: row['role'] as String),
        arguments: [email, password]);
  }

  @override
  Future<int> insertUser(UserEntity user) {
    return _userEntityInsertionAdapter.insertAndReturnId(
        user, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertUsers(List<UserEntity> users) {
    return _userEntityInsertionAdapter.insertListAndReturnIds(
        users, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    await _userEntityUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUser(UserEntity user) async {
    await _userEntityDeletionAdapter.delete(user);
  }
}

class _$PackageDao extends PackageDao {
  _$PackageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _packageEntityInsertionAdapter = InsertionAdapter(
            database,
            'PackageEntity',
            (PackageEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'author': item.author,
                  'category': item.category,
                  'description': item.description,
                  'iconUrl': item.iconUrl,
                  'language': item.language,
                  'lastUpdatedDate': item.lastUpdatedDate,
                  'level': item.level,
                  'title': item.title,
                  'version': item.version
                }),
        _packageEntityUpdateAdapter = UpdateAdapter(
            database,
            'PackageEntity',
            ['id'],
            (PackageEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'author': item.author,
                  'category': item.category,
                  'description': item.description,
                  'iconUrl': item.iconUrl,
                  'language': item.language,
                  'lastUpdatedDate': item.lastUpdatedDate,
                  'level': item.level,
                  'title': item.title,
                  'version': item.version
                }),
        _packageEntityDeletionAdapter = DeletionAdapter(
            database,
            'PackageEntity',
            ['id'],
            (PackageEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'author': item.author,
                  'category': item.category,
                  'description': item.description,
                  'iconUrl': item.iconUrl,
                  'language': item.language,
                  'lastUpdatedDate': item.lastUpdatedDate,
                  'level': item.level,
                  'title': item.title,
                  'version': item.version
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PackageEntity> _packageEntityInsertionAdapter;

  final UpdateAdapter<PackageEntity> _packageEntityUpdateAdapter;

  final DeletionAdapter<PackageEntity> _packageEntityDeletionAdapter;

  @override
  Future<List<PackageEntity>> findAllPackages() async {
    return _queryAdapter.queryList('SELECT * FROM PackageEntity',
        mapper: (Map<String, Object?> row) => PackageEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            author: row['author'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            iconUrl: row['iconUrl'] as String,
            language: row['language'] as String,
            lastUpdatedDate: row['lastUpdatedDate'] as String,
            level: row['level'] as String,
            title: row['title'] as String,
            version: row['version'] as int));
  }

  @override
  Future<PackageEntity?> findByRemoteId(String packageRemoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM PackageEntity WHERE packageRemoteId = ?1',
        mapper: (Map<String, Object?> row) => PackageEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            author: row['author'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            iconUrl: row['iconUrl'] as String,
            language: row['language'] as String,
            lastUpdatedDate: row['lastUpdatedDate'] as String,
            level: row['level'] as String,
            title: row['title'] as String,
            version: row['version'] as int),
        arguments: [packageRemoteId]);
  }

  @override
  Future<List<PackageEntity>> findByCategory(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PackageEntity WHERE category = ?1',
        mapper: (Map<String, Object?> row) => PackageEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            author: row['author'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            iconUrl: row['iconUrl'] as String,
            language: row['language'] as String,
            lastUpdatedDate: row['lastUpdatedDate'] as String,
            level: row['level'] as String,
            title: row['title'] as String,
            version: row['version'] as int),
        arguments: [category]);
  }

  @override
  Future<List<PackageEntity>> findByLevel(String level) async {
    return _queryAdapter.queryList(
        'SELECT * FROM PackageEntity WHERE level = ?1',
        mapper: (Map<String, Object?> row) => PackageEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            author: row['author'] as String,
            category: row['category'] as String,
            description: row['description'] as String,
            iconUrl: row['iconUrl'] as String,
            language: row['language'] as String,
            lastUpdatedDate: row['lastUpdatedDate'] as String,
            level: row['level'] as String,
            title: row['title'] as String,
            version: row['version'] as int),
        arguments: [level]);
  }

  @override
  Future<int> insertPackage(PackageEntity package) {
    return _packageEntityInsertionAdapter.insertAndReturnId(
        package, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertPackages(List<PackageEntity> packages) {
    return _packageEntityInsertionAdapter.insertListAndReturnIds(
        packages, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePackage(PackageEntity package) async {
    await _packageEntityUpdateAdapter.update(package, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePackage(PackageEntity package) async {
    await _packageEntityDeletionAdapter.delete(package);
  }
}

class _$WordDao extends WordDao {
  _$WordDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _wordEntityInsertionAdapter = InsertionAdapter(
            database,
            'WordEntity',
            (WordEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'text': item.text
                }),
        _wordEntityUpdateAdapter = UpdateAdapter(
            database,
            'WordEntity',
            ['id'],
            (WordEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'text': item.text
                }),
        _wordEntityDeletionAdapter = DeletionAdapter(
            database,
            'WordEntity',
            ['id'],
            (WordEntity item) => <String, Object?>{
                  'id': item.id,
                  'packageRemoteId': item.packageRemoteId,
                  'text': item.text
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<WordEntity> _wordEntityInsertionAdapter;

  final UpdateAdapter<WordEntity> _wordEntityUpdateAdapter;

  final DeletionAdapter<WordEntity> _wordEntityDeletionAdapter;

  @override
  Future<List<WordEntity>> findAllWords() async {
    return _queryAdapter.queryList('SELECT * FROM WordEntity',
        mapper: (Map<String, Object?> row) => WordEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            text: row['text'] as String));
  }

  @override
  Future<List<WordEntity>> findByPackageRemoteId(String packageRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WordEntity WHERE packageRemoteId = ?1',
        mapper: (Map<String, Object?> row) => WordEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            text: row['text'] as String),
        arguments: [packageRemoteId]);
  }

  @override
  Future<List<WordEntity>> searchByText(String searchText) async {
    return _queryAdapter.queryList(
        'SELECT * FROM WordEntity WHERE text LIKE ?1',
        mapper: (Map<String, Object?> row) => WordEntity(
            id: row['id'] as int?,
            packageRemoteId: row['packageRemoteId'] as String,
            text: row['text'] as String),
        arguments: [searchText]);
  }

  @override
  Future<int> insertWord(WordEntity word) {
    return _wordEntityInsertionAdapter.insertAndReturnId(
        word, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertWords(List<WordEntity> words) {
    return _wordEntityInsertionAdapter.insertListAndReturnIds(
        words, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateWord(WordEntity word) async {
    await _wordEntityUpdateAdapter.update(word, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteWord(WordEntity word) async {
    await _wordEntityDeletionAdapter.delete(word);
  }
}

class _$DefinitionDao extends DefinitionDao {
  _$DefinitionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _definitionEntityInsertionAdapter = InsertionAdapter(
            database,
            'DefinitionEntity',
            (DefinitionEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text,
                  'source': item.source
                }),
        _definitionEntityUpdateAdapter = UpdateAdapter(
            database,
            'DefinitionEntity',
            ['id'],
            (DefinitionEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text,
                  'source': item.source
                }),
        _definitionEntityDeletionAdapter = DeletionAdapter(
            database,
            'DefinitionEntity',
            ['id'],
            (DefinitionEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text,
                  'source': item.source
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DefinitionEntity> _definitionEntityInsertionAdapter;

  final UpdateAdapter<DefinitionEntity> _definitionEntityUpdateAdapter;

  final DeletionAdapter<DefinitionEntity> _definitionEntityDeletionAdapter;

  @override
  Future<List<DefinitionEntity>> findForWord(int wordId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM DefinitionEntity WHERE wordId = ?1',
        mapper: (Map<String, Object?> row) => DefinitionEntity(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            text: row['text'] as String,
            source: row['source'] as String),
        arguments: [wordId]);
  }

  @override
  Future<int> insertDefinition(DefinitionEntity definition) {
    return _definitionEntityInsertionAdapter.insertAndReturnId(
        definition, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertDefinitions(List<DefinitionEntity> definitions) {
    return _definitionEntityInsertionAdapter.insertListAndReturnIds(
        definitions, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateDefinition(DefinitionEntity definition) async {
    await _definitionEntityUpdateAdapter.update(
        definition, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteDefinition(DefinitionEntity definition) async {
    await _definitionEntityDeletionAdapter.delete(definition);
  }
}

class _$SentenceDao extends SentenceDao {
  _$SentenceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _sentenceEntityInsertionAdapter = InsertionAdapter(
            database,
            'SentenceEntity',
            (SentenceEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text
                }),
        _sentenceEntityUpdateAdapter = UpdateAdapter(
            database,
            'SentenceEntity',
            ['id'],
            (SentenceEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text
                }),
        _sentenceEntityDeletionAdapter = DeletionAdapter(
            database,
            'SentenceEntity',
            ['id'],
            (SentenceEntity item) => <String, Object?>{
                  'id': item.id,
                  'wordId': item.wordId,
                  'text': item.text
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SentenceEntity> _sentenceEntityInsertionAdapter;

  final UpdateAdapter<SentenceEntity> _sentenceEntityUpdateAdapter;

  final DeletionAdapter<SentenceEntity> _sentenceEntityDeletionAdapter;

  @override
  Future<List<SentenceEntity>> findForWord(int wordId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SentenceEntity WHERE wordId = ?1',
        mapper: (Map<String, Object?> row) => SentenceEntity(
            id: row['id'] as int?,
            wordId: row['wordId'] as int,
            text: row['text'] as String),
        arguments: [wordId]);
  }

  @override
  Future<int> insertSentence(SentenceEntity sentence) {
    return _sentenceEntityInsertionAdapter.insertAndReturnId(
        sentence, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertSentences(List<SentenceEntity> sentences) {
    return _sentenceEntityInsertionAdapter.insertListAndReturnIds(
        sentences, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateSentence(SentenceEntity sentence) async {
    await _sentenceEntityUpdateAdapter.update(
        sentence, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteSentence(SentenceEntity sentence) async {
    await _sentenceEntityDeletionAdapter.delete(sentence);
  }
}

class _$ResourceDao extends ResourceDao {
  _$ResourceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _resourceEntityInsertionAdapter = InsertionAdapter(
            database,
            'ResourceEntity',
            (ResourceEntity item) => <String, Object?>{
                  'id': item.id,
                  'sentenceId': item.sentenceId,
                  'title': item.title,
                  'url': item.url,
                  'type': item.type
                }),
        _resourceEntityUpdateAdapter = UpdateAdapter(
            database,
            'ResourceEntity',
            ['id'],
            (ResourceEntity item) => <String, Object?>{
                  'id': item.id,
                  'sentenceId': item.sentenceId,
                  'title': item.title,
                  'url': item.url,
                  'type': item.type
                }),
        _resourceEntityDeletionAdapter = DeletionAdapter(
            database,
            'ResourceEntity',
            ['id'],
            (ResourceEntity item) => <String, Object?>{
                  'id': item.id,
                  'sentenceId': item.sentenceId,
                  'title': item.title,
                  'url': item.url,
                  'type': item.type
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ResourceEntity> _resourceEntityInsertionAdapter;

  final UpdateAdapter<ResourceEntity> _resourceEntityUpdateAdapter;

  final DeletionAdapter<ResourceEntity> _resourceEntityDeletionAdapter;

  @override
  Future<List<ResourceEntity>> findForSentence(int sentenceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM ResourceEntity WHERE sentenceId = ?1',
        mapper: (Map<String, Object?> row) => ResourceEntity(
            id: row['id'] as int?,
            sentenceId: row['sentenceId'] as int,
            title: row['title'] as String,
            url: row['url'] as String,
            type: row['type'] as String),
        arguments: [sentenceId]);
  }

  @override
  Future<int> insertResource(ResourceEntity resource) {
    return _resourceEntityInsertionAdapter.insertAndReturnId(
        resource, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertResources(List<ResourceEntity> resources) {
    return _resourceEntityInsertionAdapter.insertListAndReturnIds(
        resources, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateResource(ResourceEntity resource) async {
    await _resourceEntityUpdateAdapter.update(
        resource, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteResource(ResourceEntity resource) async {
    await _resourceEntityDeletionAdapter.delete(resource);
  }
}
