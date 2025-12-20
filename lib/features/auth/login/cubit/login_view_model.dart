import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core/exceptions/app_exceptions.dart';
import '../../../../domain/use_cases/login_use_case.dart';
import '../../auth_cubit/auth_states.dart';

@injectable
class LoginViewModel extends Cubit<AuthState> {
  TextEditingController emailController = TextEditingController(
    text: 'oa718307@gmail.com',
  );
  TextEditingController passwordController = TextEditingController(
    text: "Omar12\$\$",
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginViewModel(this._loginUseCase) : super(AuthInitial());
  final LoginUseCase _loginUseCase;

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
      // Handle Firebase and other exceptions
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(
          11,
        ); // Remove 'Exception: ' prefix
      }
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred. Please try again."));
    }
  }
}
