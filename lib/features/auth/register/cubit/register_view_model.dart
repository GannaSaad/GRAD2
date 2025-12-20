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
  
  // Common fields
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  String selectedRole = 'patient';
  String selectedGender = 'male';

  // Doctor specific
  final specialityController = TextEditingController();
  final certificatesController = TextEditingController();

  // Patient specific
  final allergiesController = TextEditingController();
  final medicalInsuranceController = TextEditingController();

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
          phoneNumber: phoneController.text,
          gender: selectedGender,
          speciality: selectedRole == 'doctor' ? specialityController.text : null,
          certificates: selectedRole == 'doctor' ? certificatesController.text : null,
          allergies: selectedRole == 'patient' ? allergiesController.text : null,
          medicalInsurance: selectedRole == 'patient' ? medicalInsuranceController.text : null,
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
    phoneController.dispose();
    specialityController.dispose();
    certificatesController.dispose();
    allergiesController.dispose();
    medicalInsuranceController.dispose();
    return super.close();
  }
}
