import 'package:dentex_clean/domain/entities/user_entity.dart';

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
  Future<List<UserEntity>> getAllPatients();
  
  Future<void> updatePatientFinancials(String uid, double totalToPay, double totalPaid);
  
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
  });

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteUser(String uid);
}
