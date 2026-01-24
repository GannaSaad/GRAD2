import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class GetAllDoctorsUseCase {
  final AuthRepo _authRepo;

  GetAllDoctorsUseCase(this._authRepo);

  Future<List<UserEntity>> call() {
    return _authRepo.getAllDoctors();
  }
}
