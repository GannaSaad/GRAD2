import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core/exceptions/app_exceptions.dart';
import '../../../../domain/use_cases/login_use_case.dart';
import '../../../../domain/use_cases/login_with_google_use_case.dart';
import '../../auth_cubit/auth_states.dart';

@injectable
class LoginViewModel extends Cubit<AuthState> {
  TextEditingController emailController = TextEditingController(
    text: 'h.mahmoud2228@nu.edu.eg',
  );
  TextEditingController passwordController = TextEditingController(
    text: "Hana123@\$",
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  LoginViewModel(this._loginUseCase, this._loginWithGoogleUseCase) : super(AuthInitial());

  void login({required String email, required String password}) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(AuthLoading());
        final authResponse = await _loginUseCase.call(email, password);
        emit(AuthSuccess(authResponse));
      }
    } on AppExceptions catch (e) {
      emit(AuthFailure(e.toString()));
    } on DioException catch (e) {
      final message = (e.error is AppExceptions)
          ? (e.error as AppExceptions).message
          : "Something went wrong, please try again later";
      emit(AuthFailure(message));
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred. Please try again."));
    }
  }

  void loginWithGoogle() async {
    try {
      emit(AuthLoading());
      final authResponse = await _loginWithGoogleUseCase.call();
      emit(AuthSuccess(authResponse));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
