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

      // In a real app, you'd hash and compare passwords
      // For now, we'll do a simple comparison (NOT SECURE - for demo only)
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

  @override
  Future<void> updateProfile(UserEntity user) async {
    if (user.id == null) {
      throw Exception('Cannot update user without ID');
    }

    final userDb = await _userDao.findById(user.id!);
    if (userDb == null) {
      throw Exception('User not found');
    }

    final updatedUser = userDb.copyWith(
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      photoUrl: user.photoUrl,
    );

    await _userDao.updateUser(updatedUser);
    _currentUser = user;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null || _currentUser!.id == null) {
      throw Exception('No user logged in');
    }

    final userDb = await _userDao.findById(_currentUser!.id!);
    if (userDb == null) {
      throw Exception('User not found');
    }

    // Verify old password
    if (userDb.password != oldPassword) {
      throw Exception('Current password is incorrect');
    }

    // Update password
    final updatedUser = userDb.copyWith(password: newPassword);
    await _userDao.updateUser(updatedUser);
  }

  @override
  Future<void> resetPassword(String email) async {
    final userDb = await _userDao.findByEmail(email);
    if (userDb == null) {
      throw Exception('No user found with this email');
    }

    // In a real app, you'd send a reset email
    // For demo, we'll just throw a success message
    throw Exception('Password reset email sent to $email');
  }

  // Helper method - just return the entity as is since we're using the DB entity directly
  UserEntity _mapToEntity(UserEntity userDb) {
    return userDb;
  }
}
