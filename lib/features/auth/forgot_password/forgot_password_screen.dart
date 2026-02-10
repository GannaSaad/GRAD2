import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/validation.dart';
import '../../../widgets/widgets/custom_auth_item.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Reset link sent successfully! Check your inbox."),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Return to login
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Failed to send reset link"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("An unexpected error occurred"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Container(
            color: AppColors.primaryBlue,
            child: CustomAuthItem(
              text1: "Forgot Password",
              text2: "Reset your password to continue",
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Please enter your email address. You will receive a link to create a new password via email.",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomTextFormField(
                      hintText: "Enter your email",
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.grayColor),
                      validator: (val) => AppValidator.validateEmail(val),
                      controller: emailController,
                    ),
                    SizedBox(height: 32.h),
                    CustomElevatedButton(
                      buttonText: isLoading ? "Sending..." : "Send Reset Link",
                      onPressed: isLoading ? null : _handleResetPassword,
                      backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Back to Login",
                          style: AppTextStyles.normal16Grey.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
    );
  }
}
