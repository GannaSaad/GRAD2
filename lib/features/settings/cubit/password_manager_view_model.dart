import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/use_cases/update_password_use_case.dart';

abstract class PasswordManagerState {}
class PasswordManagerInitial extends PasswordManagerState {}
class PasswordManagerLoading extends PasswordManagerState {}
class PasswordManagerSuccess extends PasswordManagerState {}
class PasswordManagerFailure extends PasswordManagerState {
  final String message;
  PasswordManagerFailure(this.message);
}

@injectable
class PasswordManagerViewModel extends Cubit<PasswordManagerState> {
  final UpdatePasswordUseCase _updatePasswordUseCase;

  PasswordManagerViewModel(this._updatePasswordUseCase) : super(PasswordManagerInitial());

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      emit(PasswordManagerFailure("New passwords do not match."));
      return;
    }

    if (newPassword.length < 6) {
      emit(PasswordManagerFailure("Password must be at least 6 characters."));
      return;
    }

    emit(PasswordManagerLoading());
    try {
      await _updatePasswordUseCase.call(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(PasswordManagerSuccess());
    } catch (e) {
      emit(PasswordManagerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
