
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      hintText: "Enter your full name",
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.grayColor),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      controller: registerViewModel.nameController,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      hintText: "Enter your age",
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.grayColor),
                      validator: (val) => val == null || val.isEmpty ? "Required" : null,
                      controller: registerViewModel.ageController,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      hintText: "Enter your Email",
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                      validator: (val) => AppValidator.validateEmail(val),
                      controller: registerViewModel.emailController,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextFormField(
                      hintText: "Enter your password",
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
                      hintText: "Confirm password",
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
                    
                    SizedBox(height: 24.h),
                    CustomElevatedButton(
                      buttonText: isLoading ? "Loading..." : "Sign Up",
                      onPressed: isLoading ? null : () => registerViewModel.register(),
                      backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    _buildLoginLink(),
                  ],
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
