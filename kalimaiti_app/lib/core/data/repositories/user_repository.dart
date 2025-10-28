import '../database/app_database.dart';
import '../database/entities/user_entity.dart';
import '../database/helpers/database_helper.dart';

class UserRepository {
  late AppDatabase _database;

  Future<void> init() async {
    _database = await DatabaseHelper.getDatabase();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return await _database.userDao.findAllUsers();
  }

  Future<UserEntity?> getUserByEmail(String email) async {
    return await _database.userDao.findUserByEmail(email);
  }

  Future<UserEntity?> authenticate(String email, String password) async {
    return await _database.userDao.authenticate(email, password);
  }

  Future<int> addUser(UserEntity user) async {
    return await _database.userDao.insertUser(user);
  }

  Future<void> updateUser(UserEntity user) async {
    await _database.userDao.updateUser(user);
  }

  Future<void> deleteUser(UserEntity user) async {
    await _database.userDao.deleteUser(user);
  }
}
