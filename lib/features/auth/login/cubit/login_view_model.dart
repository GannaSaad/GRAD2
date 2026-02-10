import 'dart:async';
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
    text: 's.ayman2224@nu.edu.eg',
  );
  TextEditingController passwordController = TextEditingController(
    text: "Har1234@",
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  LoginViewModel(this._loginUseCase, this._loginWithGoogleUseCase) : super(AuthInitial());

  void login({required String email, required String password}) async {
    try {
      if (formKey.currentState!.validate()) {
        emit(AuthLoading());
        
        // Add a 10-second timeout to catch hangs
        final authResponse = await _loginUseCase.call(email, password).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception("Connection timeout. Please check your internet."),
        );
        
        emit(AuthSuccess(authResponse));
      }
    } on AppExceptions catch (e) {
      emit(AuthFailure(e.toString()));
    } on TimeoutException catch (e) {
       emit(AuthFailure("Request timed out. Please check your connection."));
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    } catch (e) {
      emit(AuthFailure("An unexpected error occurred."));
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
