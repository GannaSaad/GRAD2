import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentObscure = true;
  bool _isNewObscure = true;
  bool _isConfirmObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Password Manager", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            _buildPasswordField(
              label: "Current Password",
              controller: _currentPasswordController,
              isObscure: _isCurrentObscure,
              onToggle: () => setState(() => _isCurrentObscure = !_isCurrentObscure),
            ),
            TextButton(
              onPressed: () {},
              child: Text("Forgot Password?", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryColor)),
            ),
            SizedBox(height: 20.h),
            _buildPasswordField(
              label: "New Password",
              controller: _newPasswordController,
              isObscure: _isNewObscure,
              onToggle: () => setState(() => _isNewObscure = !_isNewObscure),
            ),
            SizedBox(height: 20.h),
            _buildPasswordField(
              label: "Confirm New Password",
              controller: _confirmPasswordController,
              isObscure: _isConfirmObscure,
              onToggle: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.r),
        child: CustomElevatedButton(
          buttonText: "Change Password",
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Password changed successfully!")),
            );
          },
          backgroundColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.titleSmall),
        SizedBox(height: 8.h),
        CustomTextFormField(
          hintText: "Enter $label",
          controller: controller,
          isObscure: isObscure,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            onPressed: onToggle,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
