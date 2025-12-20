import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    required String age,
    required String role,
  });

  Future<UserEntity> login({
    required String email,
    required String password
  });
}
