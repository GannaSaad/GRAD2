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
  }) {
    return _authRepo.register(
      email: email,
      password: password,
      name: name,
      age: age,
      role: role,
    );
  }
}
