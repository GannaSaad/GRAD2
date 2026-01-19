import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/validation.dart';
import '../../../widgets/widgets/custom_auth_item.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../auth_cubit/auth_states.dart';
import 'cubit/register_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel registerViewModel = getIt<RegisterViewModel>();
  bool isObscure = true;
  bool isConfirmObscure = true;
  bool hasAllergies = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterViewModel, AuthState>(
        bloc: registerViewModel,
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
          }
        },
        child: BlocBuilder<RegisterViewModel, AuthState>(
          bloc: registerViewModel,
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomAuthItem(
              text1: "Create Account",
              text2: "Sign up to get started",
              child: Form(
                key: registerViewModel.formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        hintText: "Full Name",
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.nameController,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              hintText: "Age",
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.grayColor),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                              controller: registerViewModel.ageController,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(child: _buildGenderDropdown()),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Phone Number",
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.grayColor),
                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                        controller: registerViewModel.phoneController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                        validator: (val) => AppValidator.validateEmail(val),
                        controller: registerViewModel.emailController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Password",
                        prefixIcon: Icon(Icons.lock_open_sharp, color: AppColors.grayColor),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => isObscure = !isObscure),
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grayColor),
                        ),
                        isObscure: isObscure,
                        validator: (val) => AppValidator.validatePassword(val),
                        controller: registerViewModel.passwordController,
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        hintText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock_open_sharp, color: AppColors.grayColor),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => isConfirmObscure = !isConfirmObscure),
                          icon: Icon(isConfirmObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grayColor),
                        ),
                        isObscure: isConfirmObscure,
                        validator: (val) => val != registerViewModel.passwordController.text ? "No match" : null,
                        controller: registerViewModel.confirmPasswordController,
                      ),
                      SizedBox(height: 16.h),
                      
                      _buildRoleDropdown(),
                      SizedBox(height: 16.h),

                      if (registerViewModel.selectedRole == 'doctor') ...[
                        CustomTextFormField(
                          hintText: "Speciality (e.g. Implantologist)",
                          prefixIcon: Icon(Icons.medical_services_outlined, color: AppColors.grayColor),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          controller: registerViewModel.specialityController,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          hintText: "Rank (e.g. Senior Specialist)",
                          prefixIcon: Icon(Icons.badge_outlined, color: AppColors.grayColor),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          controller: registerViewModel.rankController,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          hintText: "Years Experience",
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.history_outlined, color: AppColors.grayColor),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          controller: registerViewModel.experienceController,
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          hintText: "Education (e.g. Cairo University)",
                          prefixIcon: Icon(Icons.school_outlined, color: AppColors.grayColor),
                          validator: (val) => val == null || val.isEmpty ? "Required" : null,
                          controller: registerViewModel.educationController,
                        ),
                        SizedBox(height: 16.h),
                        _buildCertificatePicker(),
                      ] else ...[
                         _buildAllergyToggle(),
                        if (hasAllergies) ...[
                          SizedBox(height: 10.h),
                          _buildAllergyPicker(),
                        ],
                        SizedBox(height: 16.h),
                        _buildInsuranceToggle(),
                      ],
                      
                      SizedBox(height: 24.h),
                      CustomElevatedButton(
                        buttonText: isLoading ? "Loading..." : "Sign Up",
                        onPressed: isLoading ? null : () => registerViewModel.register(),
                        backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                      ),
                      SizedBox(height: 16.h),
                      _buildLoginLink(),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: registerViewModel.selectedRole,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'patient', child: Text("Patient", style: AppTextStyles.normal16Grey)),
            DropdownMenuItem(value: 'doctor', child: Text("Doctor", style: AppTextStyles.normal16Grey)),
          ],
          onChanged: (val) => setState(() => registerViewModel.selectedRole = val!),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
     return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.borderMedium),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: registerViewModel.selectedGender,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: 'male', child: Text("Male", style: AppTextStyles.normal16Grey)),
            DropdownMenuItem(value: 'female', child: Text("Female", style: AppTextStyles.normal16Grey)),
          ],
          onChanged: (val) => setState(() => registerViewModel.selectedGender = val!),
        ),
      ),
    );
  }

  Widget _buildCertificatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upload Professional Certificate", style: AppTextStyles.normal16Grey),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => registerViewModel.pickCertificate(),
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderMedium, style: BorderStyle.solid),
              color: AppColors.lightGreyColor,
            ),
            child: registerViewModel.certificateFile != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(registerViewModel.certificateFile!, fit: BoxFit.cover),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppColors.primaryColor, size: 32.r),
                    SizedBox(height: 8.h),
                    Text("Select Certificate Photo", style: AppTextStyles.regular12Gray),
                  ],
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllergyToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Do you have allergies?", style: AppTextStyles.normal16Grey),
        Switch(
          value: hasAllergies,
          onChanged: (val) {
            setState(() {
              hasAllergies = val;
              if (!val) {
                registerViewModel.allergiesController.text = "None";
              }
            });
          },
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildAllergyPicker() {
    List<String> allergies = ["Penicillin", "Latex", "Pollen", "Other"];
    String currentText = registerViewModel.allergiesController.text;
    String dropdownValue = allergies.contains(currentText) ? currentText : "Other";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.borderMedium),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              isExpanded: true,
              items: allergies.map((String allergy) {
                return DropdownMenuItem(value: allergy, child: Text(allergy, style: AppTextStyles.normal16Grey));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (val != "Other") {
                    registerViewModel.allergiesController.text = val!;
                  } else {
                    registerViewModel.allergiesController.text = "";
                  }
                });
              },
            ),
          ),
        ),
        if (dropdownValue == "Other") ...[
          SizedBox(height: 10.h),
          CustomTextFormField(
            hintText: "Specify Allergy",
            prefixIcon: Icon(Icons.warning_amber_outlined, color: AppColors.grayColor),
            controller: registerViewModel.allergiesController,
          ),
        ],
      ],
    );
  }

  Widget _buildInsuranceToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Medical Insurance", style: AppTextStyles.normal16Grey),
        Switch(
          value: registerViewModel.medicalInsuranceController.text == "Yes",
          onChanged: (val) {
            setState(() {
              registerViewModel.medicalInsuranceController.text = val ? "Yes" : "No";
            });
          },
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?", style: AppTextStyles.normal16Grey.copyWith(fontSize: 15)),
        SizedBox(width: 6.w),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.login),
          child: Text("Login", style: AppTextStyles.normal16Grey.copyWith(color: AppColors.primaryColor, fontSize: 15)),
        ),
      ],
    );
  }
}
