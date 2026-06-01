import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class LoginWithGoogleUseCase {
  final AuthRepo _authRepository;

  LoginWithGoogleUseCase(this._authRepository);

  Future<UserEntity> call() {
    return _authRepository.loginWithGoogle();
  }
}
