import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../../auth/auth_cubit/auth_states.dart';
import '../../auth/login/cubit/login_view_model.dart';
import '../../auth/register/cubit/register_view_model.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final loginViewModel = getIt<LoginViewModel>();
    final registerViewModel = getIt<RegisterViewModel>();
    
    dynamic user;
    if (loginViewModel.state is AuthSuccess) {
      user = (loginViewModel.state as AuthSuccess).user;
    } else if (registerViewModel.state is AuthSuccess) {
      user = (registerViewModel.state as AuthSuccess).user;
    }

    _nameController = TextEditingController(text: user?.fullName ?? "");
    _phoneController = TextEditingController(text: user?.phoneNumber ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Profile", style: AppTextStyles.bold18White.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primaryColor),
            onPressed: () {
              // Navigate to settings if needed, but the request says settings icon here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildAvatarSection(),
            SizedBox(height: 40.h),
            CustomTextFormField(
              hintText: "Full Name",
              controller: _nameController,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            SizedBox(height: 20.h),
            CustomTextFormField(
              hintText: "Phone Number",
              controller: _phoneController,
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20.h),
            CustomTextFormField(
              hintText: "Email",
              controller: _emailController,
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 100.h), // Space for button
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20.r),
        child: CustomElevatedButton(
          buttonText: "Update Profile",
          onPressed: () {
            // Logic to update profile
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Profile updated successfully!")),
            );
          },
          backgroundColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60.r,
          backgroundColor: AppColors.primaryBlueSoft,
          child: Icon(Icons.person, size: 60.r, color: AppColors.primaryColor),
        ),
        Container(
          height: 35.r,
          width: 35.r,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20.r),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
