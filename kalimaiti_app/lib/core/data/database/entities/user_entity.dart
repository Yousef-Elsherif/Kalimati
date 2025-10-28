import 'package:floor/floor.dart';

@entity
class UserEntity {
  @primaryKey
  final int? id;

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String photoUrl;
  final String role;

  UserEntity({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.photoUrl,
    required this.role,
  });
}
