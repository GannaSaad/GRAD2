import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class RegisterUseCase {
  final AuthRepo _authRepo;

  RegisterUseCase(this._authRepo);

  Future<UserEntity> execute({
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
  }) {
    return _authRepo.register(
      email: email,
      password: password,
      name: name,
      age: age,
      role: role,
      phoneNumber: phoneNumber,
      gender: gender,
      speciality: speciality,
      rank: rank,
      experience: experience,
      education: education,
      certificates: certificates,
      allergies: allergies,
      medicalInsurance: medicalInsurance,
    );
  }
}
