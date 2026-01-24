import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class RegisterStaffUseCase {
  final AuthRepo _authRepo;

  RegisterStaffUseCase(this._authRepo);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String name,
    required String role,
  }) {
    // We reuse the existing register method with minimal fields for staff
    return _authRepo.register(
      email: email,
      password: password,
      name: name,
      role: role,
      age: "N/A",
      phoneNumber: "N/A",
      gender: "N/A",
    );
  }
}
