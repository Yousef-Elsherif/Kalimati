import 'package:kalimaiti_app/core/data/database/entities/user_entity.dart';

abstract class AuthRepository {
  // Sign in with email and password
  Future<UserEntity?> signIn(String email, String password);

  // Sign out current user
  Future<void> signOut();

  // Get current logged in user
  Future<UserEntity?> getCurrentUser();

  // Check if user is logged in
  Future<bool> isLoggedIn();
}
