
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/cubit/theme_cubit.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../auth/auth_cubit/auth_states.dart';
import '../../auth/login/cubit/login_view_model.dart';
import '../../auth/register/cubit/register_view_model.dart';
import '../../../api/config/di/di.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    // We can try to get the user from either LoginViewModel or RegisterViewModel success state
    // In a real app, you'd likely have a global AuthCubit
    final loginViewModel = getIt<LoginViewModel>();
    final registerViewModel = getIt<RegisterViewModel>();
    
    dynamic currentUser;
    if (loginViewModel.state is AuthSuccess) {
      currentUser = (loginViewModel.state as AuthSuccess).user;
    } else if (registerViewModel.state is AuthSuccess) {
      currentUser = (registerViewModel.state as AuthSuccess).user;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile", style: AppTextStyles.bold18White.copyWith(color: AppColors.primaryColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          children: [
            _buildProfileHeader(currentUser),
            SizedBox(height: 30.h),
            _buildInfoSection(currentUser),
            SizedBox(height: 30.h),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60.r,
              backgroundColor: AppColors.primaryBlueSoft,
              child: Icon(Icons.person, size: 60.r, color: AppColors.primaryColor),
            ),
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.primaryColor,
              child: Icon(Icons.camera_alt, size: 18.r, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          user?.fullName ?? "User Name",
          style: AppTextStyles.bold18White.copyWith(color: AppColors.textPrimary),
        ),
        Text(
          user?.email ?? "email@example.com",
          style: AppTextStyles.normal16Grey,
        ),
      ],
    );
  }

  Widget _buildInfoSection(dynamic user) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, "Full Name", user?.fullName ?? "Not set"),
          const Divider(),
          _buildInfoRow(Icons.email_outlined, "Email", user?.email ?? "Not set"),
          const Divider(),
          _buildInfoRow(Icons.calendar_today_outlined, "Age / Phone", user?.age ?? "Not set"),
          const Divider(),
          _buildInfoRow(Icons.work_outline, "Role", user?.role ?? "Patient"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24.r),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.regular12Gray),
              Text(value, style: AppTextStyles.medium14black.copyWith(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CustomElevatedButton(
      buttonText: "Logout",
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
      },
      backgroundColor: Colors.red.shade400,
    );
  }
}
