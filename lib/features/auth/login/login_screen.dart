import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/cubit/theme_cubit.dart';
import '../../../core/core/utils/validation.dart';
import '../../../widgets/widgets/custom_auth_item.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../auth_cubit/auth_cubit.dart';
import '../auth_cubit/auth_states.dart';
import '../forgot_password/forgot_password_screen.dart';
import 'cubit/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  LoginViewModel loginViewModel = getIt<LoginViewModel>();
  bool isObscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: BlocListener<LoginViewModel, AuthState>(
        bloc: loginViewModel,
        listener: (BuildContext context, AuthState state) {
          if (state is AuthLoading) {
            setState(() => isLoading = true);
          } else if (state is AuthFailure) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is AuthSuccess) {
            setState(() => isLoading = false);
            getIt<AuthCubit>().updateAuthenticatedUser(state.user);
            Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Container(
              color: AppColors.primaryBlue,
              child: CustomAuthItem(
                text1: "Welcome back",
                text2: "Sign in to continue",
                child: Form(
                  key: loginViewModel.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextFormField(
                        hintText: "Enter your Email or Phone",
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                        validator: (val) => AppValidator.validateEmail(val),
                        controller: loginViewModel.emailController,
                      ),
                      SizedBox(height: 20.h),
                      CustomTextFormField(
                        hintText: "Enter your password",
                        prefixIcon: Icon(Icons.lock_open_sharp, color: AppColors.grayColor),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => isObscure = !isObscure),
                          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: AppColors.grayColor),
                        ),
                        isObscure: isObscure,
                        validator: (val) => AppValidator.validatePassword(val),
                        controller: loginViewModel.passwordController,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Forgot Password",
                              style: AppTextStyles.normal16Grey.copyWith(
                                color: AppColors.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      CustomElevatedButton(
                        buttonText: isLoading ? "Loading..." : "login",
                        onPressed: isLoading ? null : () => loginViewModel.login(
                          email: loginViewModel.emailController.text.trim(), 
                          password: loginViewModel.passwordController.text
                        ),
                        backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account", style: AppTextStyles.normal16Grey.copyWith(fontSize: 15)),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                            child: Text("Sign up", style: AppTextStyles.normal16Grey.copyWith(color: AppColors.primaryColor, fontSize: 15)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.grayColor, thickness: 2, endIndent: 10.w, indent: 10.w)),
                          Text("OR", style: AppTextStyles.normal16Grey.copyWith(fontSize: 15)),
                          Expanded(child: Divider(color: AppColors.grayColor, thickness: 2, endIndent: 10.w, indent: 10.w)),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      CustomElevatedButton(
                        onPressed: isLoading ? null : () => loginViewModel.loginWithGoogle(),
                        iconExists: true,
                        backgroundColor: ThemeCubit.isDark() ? AppColors.darkCard : AppColors.whiteColor,
                        borderSideColor: AppColors.grayColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AppImages.googleIcon, height: 20.h, width: 20.w),
                            SizedBox(width: 8.w),
                            Text("Continue with Google", style: AppTextStyles.medium16White.copyWith(color: AppColors.placeholderTextColor)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
