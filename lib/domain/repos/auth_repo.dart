import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    required String age,
    required String role,
    required String phoneNumber,
    required String gender,
    String? speciality,
    String? rank,
    String? experience,
    String? education,
    String? certificates,
    String? allergies,
    String? medicalInsurance,
  });

  Future<UserEntity> login({
    required String email, 
    required String password
  });

  Future<UserEntity> getUserData(String uid);
  Future<UserEntity> loginWithGoogle();
  Future<List<UserEntity>> getAllDoctors();
}
