import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_entity.dart';
import 'auth_states.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void updateAuthenticatedUser(UserEntity user) {
    emit(AuthSuccess(user));
  }

  UserEntity? get currentUser {
    if (state is AuthSuccess) {
      return (state as AuthSuccess).user;
    }
    return null;
  }
}
