import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import 'cubit/password_manager_view_model.dart';

class PasswordManagerScreen extends StatefulWidget {
  const PasswordManagerScreen({super.key});

  @override
  State<PasswordManagerScreen> createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final PasswordManagerViewModel _viewModel = getIt<PasswordManagerViewModel>();

  bool _isCurrentObscure = true;
  bool _isNewObscure = true;
  bool _isConfirmObscure = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Password Manager", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocListener<PasswordManagerViewModel, PasswordManagerState>(
          listener: (context, state) {
            if (state is PasswordManagerSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password changed successfully! Please log in with your new password."), backgroundColor: Colors.green),
              );
              Navigator.pop(context);
            } else if (state is PasswordManagerFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
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
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20.r),
          child: BlocBuilder<PasswordManagerViewModel, PasswordManagerState>(
            builder: (context, state) {
              bool isLoading = state is PasswordManagerLoading;
              return CustomElevatedButton(
                buttonText: isLoading ? "Updating..." : "Change Password",
                onPressed: isLoading ? null : () {
                  _viewModel.updatePassword(
                    currentPassword: _currentPasswordController.text,
                    newPassword: _newPasswordController.text,
                    confirmPassword: _confirmPasswordController.text,
                  );
                },
                backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryBlue,
              );
            },
          ),
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
