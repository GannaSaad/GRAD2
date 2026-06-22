import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/core/exceptions/app_exceptions.dart';
import '../../../../domain/use_cases/login_use_case.dart';
import '../../../../domain/use_cases/login_with_google_use_case.dart';
import '../../auth_cubit/auth_states.dart';

@injectable
class LoginViewModel extends Cubit<AuthState> {
  // Pre-filled for development - ensure these are cleared for production
  TextEditingController emailController = TextEditingController(
    text: 'hanaelashry20@gmail.com',
  );
  TextEditingController passwordController = TextEditingController(
    text: "Hana123@",
  );

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final LoginUseCase _loginUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;

  LoginViewModel(this._loginUseCase, this._loginWithGoogleUseCase) : super(AuthInitial());

  /// Standard Email/Password Login
  void login({required String email, required String password}) async {
    // 1. Validate Input before starting
    if (email.isEmpty || password.isEmpty) {
      emit(AuthFailure("Email and password cannot be empty."));
      return;
    }

    try {
      if (formKey.currentState?.validate() ?? false) {
        emit(AuthLoading());

        // 2. Call UseCase with Timeout to prevent infinite "Just Running" state
        final authResponse = await _loginUseCase.call(email, password).timeout(
          const Duration(seconds: 15), // Increased to 15s for slower networks
          onTimeout: () {
            throw TimeoutException("The server took too long to respond. Please try again.");
          },
        );

        // 3. Null-safety check on the response object
        if (authResponse != null) {
          emit(AuthSuccess(authResponse));
        } else {
          emit(AuthFailure("Received empty response from server."));
        }
      }
    } on AppExceptions catch (e) {
      emit(AuthFailure(e.toString()));
    } on TimeoutException catch (e) {
      emit(AuthFailure(e.message ?? "Connection timeout."));
    } on TypeError catch (e) {
      // THIS CATCHES: "type 'Null' is not a subtype of type 'String'"
      debugPrint("Data Parsing Error: ${e.toString()}");
      emit(AuthFailure("Internal Data Error: A required field was missing from the server."));
    } on Exception catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      emit(AuthFailure(errorMessage));
    } catch (e) {
      debugPrint("Unexpected Error: $e");
      emit(AuthFailure("An unexpected error occurred. Please try again later."));
    }
  }

  /// Google Social Login
  void loginWithGoogle() async {
    try {
      emit(AuthLoading());

      final authResponse = await _loginWithGoogleUseCase.call();

      if (authResponse != null) {
        emit(AuthSuccess(authResponse));
      } else {
        // User likely cancelled the Google Sign-in popup
        emit(AuthInitial());
      }
    } on TypeError catch (e) {
      debugPrint("Google Auth Parsing Error: ${e.toString()}");
      emit(AuthFailure("Failed to process Google account data."));
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}