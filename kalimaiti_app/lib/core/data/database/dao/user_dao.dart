import 'package:floor/floor.dart';
import '../entities/user_entity.dart';

@dao
abstract class UserDao {
  @Query('SELECT * FROM UserEntity')
  Future<List<UserEntity>> findAllUsers();

  @Query('SELECT * FROM UserEntity WHERE email = :email')
  Future<UserEntity?> findUserByEmail(String email);

  @Query(
    'SELECT * FROM UserEntity WHERE email = :email AND password = :password',
  )
  Future<UserEntity?> authenticate(String email, String password);

  @insert
  Future<int> insertUser(UserEntity user);

  @insert
  Future<List<int>> insertUsers(List<UserEntity> users);

  @update
  Future<void> updateUser(UserEntity user);

  @delete
  Future<void> deleteUser(UserEntity user);
}
