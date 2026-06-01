import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/get_user_data_use_case.dart';
import 'auth_states.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final GetUserDataUseCase _getUserDataUseCase;

  AuthCubit(this._getUserDataUseCase) : super(AuthInitial());

  void updateAuthenticatedUser(UserEntity user) {
    emit(AuthSuccess(user));
  }

  void loadUserData() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final user = await _getUserDataUseCase.call(firebaseUser.uid);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Logout failed: ${e.toString()}"));
    }
  }

  UserEntity? get currentUser {
    if (state is AuthSuccess) {
      return (state as AuthSuccess).user;
    }
    return null;
  }
}
