import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/use_cases/update_profile_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class ProfileState {}
class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileSuccess extends ProfileState {}
class ProfileFailure extends ProfileState {
  final String message;
  ProfileFailure(this.message);
}

@injectable
class ProfileViewModel extends Cubit<ProfileState> {
  final UpdateProfileUseCase _updateProfileUseCase;

  ProfileViewModel(this._updateProfileUseCase) : super(ProfileInitial());

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    final authCubit = getIt<AuthCubit>();
    final user = authCubit.currentUser;
    
    if (user == null) {
      emit(ProfileFailure("User not authenticated"));
      return;
    }

    emit(ProfileLoading());
    try {
      await _updateProfileUseCase.call(
        uid: user.uid,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      
      // Update the local AuthCubit state so UI reflects changes everywhere
      final updatedUser = user.copyWith(
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
      authCubit.updateAuthenticatedUser(updatedUser);
      
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

// Add copyWith to UserEntity if not present
extension UserEntityExtension on dynamic {
  // This is a helper since I can't easily modify the original class if it lacks copyWith
}
