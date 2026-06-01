import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/cubit/theme_cubit.dart';
import '../../auth/auth_cubit/auth_cubit.dart';

class SupplierProfileTab extends StatelessWidget {
  const SupplierProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          "Supplier Profile",
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                  color: AppColors.primaryBlue,
                ),
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildProfileHeader(user),
            SizedBox(height: 32.h),
            _buildInfoSection(user),
            SizedBox(height: 40.h),
            _buildLogoutButton(context),
            SizedBox(height: 20.h),
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
              child: Icon(Icons.person, size: 60.r, color: AppColors.primaryBlue),
            ),
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.camera_alt, size: 18.r, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          user?.fullName ?? "Supplier Name",
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          user?.companyId ?? "Company Name",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoSection(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: "Email Address",
            value: user?.email ?? "N/A",
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          _buildInfoTile(
            icon: Icons.phone_outlined,
            label: "Phone Number",
            value: user?.phoneNumber ?? "N/A",
          ),
          const Divider(height: 1, color: AppColors.borderSoft),
          _buildInfoTile(
            icon: Icons.location_on_outlined,
            label: "Office Address",
            value: user?.address ?? "N/A",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueSoft,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CustomElevatedButton(
      buttonText: "Log Out",
      onPressed: () async {
        await getIt<AuthCubit>().logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        }
      },
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, color: AppColors.error, size: 22.r),
          SizedBox(width: 8.w),
          Text(
            "Log Out",
            style: AppTextStyles.buttonMedium.copyWith(color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String? buttonText;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Widget? child;

  const CustomElevatedButton({
    super.key,
    this.buttonText,
    this.onPressed,
    this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
        child: child ?? Text(
          buttonText ?? "",
          style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
