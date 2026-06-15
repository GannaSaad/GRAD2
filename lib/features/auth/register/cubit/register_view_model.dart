import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  // Supplier/Company specific
  String? selectedCompany;
  final addressController = TextEditingController();

  // Doctor specific fields
  final specialityController = TextEditingController();
  final rankController = TextEditingController();
  final experienceController = TextEditingController();
  final educationController = TextEditingController();
  final clinicNameController = TextEditingController(); // Added Clinic Name Controller
  File? certificateFile;

  // Patient specific fields
  final allergiesController = TextEditingController();
  final medicalInsuranceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> pickCertificate() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        certificateFile = File(image.path);
        emit(AuthInitial()); 
      }
    } catch (e) {
      emit(AuthFailure("Failed to pick image: ${e.toString()}"));
    }
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      if (selectedRole == 'doctor' && certificateFile == null) {
        emit(AuthFailure("Please upload your professional certificate"));
        return;
      }

      emit(AuthLoading());
      try {
        final user = await _registerUseCase.execute(
          email: emailController.text.trim(),
          password: passwordController.text,
          name: nameController.text.trim(),
          age: ageController.text.trim(),
          role: selectedRole,
          phoneNumber: phoneController.text.trim(),
          gender: selectedGender,
          speciality: selectedRole == 'doctor' ? specialityController.text : null,
          rank: selectedRole == 'doctor' ? rankController.text : null,
          experience: selectedRole == 'doctor' ? experienceController.text : null,
          education: selectedRole == 'doctor' ? educationController.text : null,
          certificates: selectedRole == 'doctor' ? "verified_by_it" : null,
          clinicName: selectedRole == 'doctor' ? clinicNameController.text.trim() : null, // Added Clinic Name
          allergies: selectedRole == 'patient' ? allergiesController.text : null,
          medicalInsurance: selectedRole == 'patient' ? medicalInsuranceController.text : null,
          companyId: selectedRole == 'supplier' ? selectedCompany : null,
          address: selectedRole == 'supplier' ? addressController.text : null,
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
    rankController.dispose();
    experienceController.dispose();
    educationController.dispose();
    clinicNameController.dispose(); // Dispose Clinic Name Controller
    allergiesController.dispose();
    medicalInsuranceController.dispose();
    addressController.dispose();
    return super.close();
  }
}
