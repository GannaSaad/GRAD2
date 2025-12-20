
import 'package:injectable/injectable.dart';

import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class LoginUseCase {
  final AuthRepo _authRepository; // Injects the interface, not the implementation

  LoginUseCase(this._authRepository);

  Future<UserEntity> call(String email, String password) {
    return _authRepository.login(email: email, password: password);
  }
}