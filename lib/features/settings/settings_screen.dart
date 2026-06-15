import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../auth/auth_cubit/auth_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final String role = (authCubit.currentUser?.role ?? 'patient').toLowerCase();
    
    // Logic to identify staff/doctors/admins who shouldn't delete accounts
    final bool isStaffOrDoctor = role == 'doctor' || role == 'nurse' || role == 'receptionist' || role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
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
              _buildSettingItem(
                icon: Icons.notifications_none_outlined,
                label: "Notification Settings",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notificationSettings);
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.lock_outline,
                label: "Password Manager",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.passwordManager);
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                icon: Icons.location_on_outlined,
                label: "Location Permission",
                onTap: () {
                  _showLocationPermissionModal(context);
                },
              ),
              // Only hide the Delete Account option for staff and doctors
              if (!isStaffOrDoctor) ...[
                const Divider(height: 1),
                _buildSettingItem(
                  icon: Icons.delete_outline,
                  label: "Delete Account",
                  isDestructive: true,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : AppColors.primaryBlueSoft,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : AppColors.primaryColor, size: 22.r),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isDestructive ? Colors.red : AppColors.textTertiary, size: 20.r),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  void _showLocationPermissionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      backgroundColor: AppColors.whiteColor,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 4.h, width: 40.w, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2.r))),
              SizedBox(height: 24.h),
              Text("Allow Location", style: AppTextStyles.titleLarge),
              SizedBox(height: 16.h),
              Text(
                "Dentix needs access to your location to find nearby doctors and clinics. Do you want to share your location?",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        side: const BorderSide(color: AppColors.borderMedium),
                      ),
                      child: Text("Cancel", style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission granted!")));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text("Yes", style: AppTextStyles.buttonMedium),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
