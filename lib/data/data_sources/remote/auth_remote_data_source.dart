import 'package:dentex_clean/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
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
  Future<UserModel> getUserData(String uid);
  Future<UserModel> loginWithGoogle();
  Future<List<UserModel>> getAllDoctors();
  Future<List<UserModel>> getAllPatients(); // Added this line
  Stream<List<UserModel>> getDoctorsStream();
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
