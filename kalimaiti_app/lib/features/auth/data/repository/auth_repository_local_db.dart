import 'package:kalimaiti_app/core/data/database/dao/user_dao.dart';
import 'package:kalimaiti_app/core/data/database/entities/user_entity.dart';
import 'package:kalimaiti_app/features/auth/domain/contracts/auth_repository.dart';

class AuthRepositoryLocalDb implements AuthRepository {
  final UserDao _userDao;
  UserEntity? _currentUser;

  AuthRepositoryLocalDb(this._userDao);

  @override
  Future<UserEntity?> signIn(String email, String password) async {
    try {
      final userDb = await _userDao.findByEmail(email);

      if (userDb == null) {
        throw Exception('User not found');
      }

      if (userDb.password != password) {
        throw Exception('Invalid password');
      }

      _currentUser = _mapToEntity(userDb);
      return _currentUser;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _currentUser != null;
  }

  UserEntity _mapToEntity(UserEntity userDb) {
    return userDb;
  }
}
