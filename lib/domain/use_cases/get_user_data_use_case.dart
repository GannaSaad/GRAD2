import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class GetUserDataUseCase {
  final AuthRepo _authRepository;

  GetUserDataUseCase(this._authRepository);

  Future<UserEntity> call(String uid) {
    return _authRepository.getUserData(uid);
  }
}
