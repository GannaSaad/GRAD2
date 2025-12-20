import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? age;
  final String? role;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.age,
    this.role,
  });

  factory UserModel.fromFirebaseUser(
      User user, {
        String? fullName,
        String? age,
        String? role,
      }) {
    return UserModel(
      id: user.uid,
      email: user.email,
      fullName: fullName ?? user.displayName,
      age: age,
      role: role,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: id,
      email: email ?? '',
      fullName: fullName ?? '',
      age: age,
      role: role,
    );
  }
}
