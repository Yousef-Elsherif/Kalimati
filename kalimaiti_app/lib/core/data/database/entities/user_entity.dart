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

  String get fullName => '$firstName $lastName'.trim();

  String get avatarUrl => photoUrl;

  UserEntity copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? photoUrl,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}
