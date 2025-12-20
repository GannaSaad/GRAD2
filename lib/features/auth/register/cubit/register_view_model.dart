import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import '../../auth_cubit/auth_states.dart';

@injectable
class RegisterViewModel extends Cubit<AuthState> {
  final RegisterUseCase _registerUseCase;

  RegisterViewModel(this._registerUseCase) : super(AuthInitial());

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedRole = 'patient';

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      emit(AuthLoading());
      try {
        final user = await _registerUseCase.execute(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          age: ageController.text,
          role: selectedRole,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
