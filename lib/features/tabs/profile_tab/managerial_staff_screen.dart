import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class ManagerialStaffScreen extends StatefulWidget {
  const ManagerialStaffScreen({super.key});

  @override
  State<ManagerialStaffScreen> createState() => _ManagerialStaffScreenState();
}

class _ManagerialStaffScreenState extends State<ManagerialStaffScreen> {
  String? _selectedRole; // 'receptionist' or 'assistant'
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Managerial Staff", style: AppTextStyles.bold18White.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _selectedRole == null ? _buildSelectionView() : _buildCreateAccountForm(),
    );
  }

  Widget _buildSelectionView() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select Staff Role", style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text("Choose the type of account you want to create", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          SizedBox(height: 32.h),
          _buildRoleCard(
            title: "Receptionist",
            subtitle: "Manage appointments and patient registration",
            icon: Icons.desk_outlined,
            onTap: () => setState(() => _selectedRole = 'receptionist'),
          ),
          SizedBox(height: 16.h),
          _buildRoleCard(
            title: "Doctor Assistant",
            subtitle: "Assist with medical records and patient care",
            icon: Icons.support_agent_outlined,
            onTap: () => setState(() => _selectedRole = 'assistant'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueSoft,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  onPressed: () => setState(() => _selectedRole = null),
                ),
                Text(
                  "Create ${_selectedRole == 'receptionist' ? 'Receptionist' : 'Assistant'} Account",
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _buildLabel("Full Name"),
            CustomTextFormField(
              hintText: "Enter full name",
              controller: _nameController,
              prefixIcon: const Icon(Icons.person_outline),
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 20.h),
            _buildLabel("Email Address"),
            CustomTextFormField(
              hintText: "Enter email address",
              controller: _emailController,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (val) => val!.isEmpty ? "Required" : null,
            ),
            SizedBox(height: 20.h),
            _buildLabel("Password"),
            CustomTextFormField(
              hintText: "Create a secure password",
              controller: _passwordController,
              isObscure: true,
              prefixIcon: const Icon(Icons.lock_outline),
              validator: (val) => val!.length < 6 ? "Minimum 6 characters" : null,
            ),
            SizedBox(height: 40.h),
            CustomElevatedButton(
              buttonText: "Create Account",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _showSuccessDialog();
                }
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 16.h),
            Text("Success!", style: AppTextStyles.headlineSmall),
            SizedBox(height: 8.h),
            Text(
              "Account for ${_nameController.text} has been created as a ${_selectedRole}.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: 24.h),
            CustomElevatedButton(
              buttonText: "Done",
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Profile
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
