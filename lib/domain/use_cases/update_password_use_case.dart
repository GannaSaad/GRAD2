import 'package:injectable/injectable.dart';
import '../repos/auth_repo.dart';

@injectable
class UpdatePasswordUseCase {
  final AuthRepo _authRepo;

  UpdatePasswordUseCase(this._authRepo);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authRepo.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
