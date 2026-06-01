import 'package:injectable/injectable.dart';
import '../repos/auth_repo.dart';

@injectable
class UpdateProfileUseCase {
  final AuthRepo _authRepo;

  UpdateProfileUseCase(this._authRepo);

  Future<void> call({
    required String uid,
    required String fullName,
    required String phoneNumber,
  }) {
    return _authRepo.updateProfile(
      uid: uid,
      fullName: fullName,
      phoneNumber: phoneNumber,
    );
  }
}
