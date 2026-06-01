import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import 'cubit/profile_view_model.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _role;
  final ProfileViewModel _viewModel = getIt<ProfileViewModel>();

  @override
  void initState() {
    super.initState();
    final authCubit = getIt<AuthCubit>();
    final user = authCubit.currentUser;

    _nameController = TextEditingController(text: user?.fullName ?? "");
    _phoneController = TextEditingController(text: user?.phoneNumber ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _role = (user?.role ?? 'patient').toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    bool isStaff = _role == 'nurse' || _role == 'receptionist' || _role == 'assistant';

    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Edit Profile", style: AppTextStyles.bold18White.copyWith(color: AppColors.primaryColor)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocListener<ProfileViewModel, ProfileState>(
          listener: (context, state) {
            if (state is ProfileSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
              );
            } else if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
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
                  readOnly: true, // Email change usually requires re-auth, so we keep it read-only here for simplicity
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                if (isStaff)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      "Email change is disabled for staff accounts.",
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                    ),
                  ),
                SizedBox(height: 40.h), 
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(20.r),
          child: BlocBuilder<ProfileViewModel, ProfileState>(
            builder: (context, state) {
              bool isLoading = state is ProfileLoading;
              return CustomElevatedButton(
                buttonText: isLoading ? "Updating..." : "Update Profile",
                onPressed: isLoading ? null : () {
                  _viewModel.updateProfile(
                    fullName: _nameController.text.trim(),
                    phoneNumber: _phoneController.text.trim(),
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
