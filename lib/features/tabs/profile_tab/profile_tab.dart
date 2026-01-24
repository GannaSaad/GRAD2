import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../core/core/utils/cubit/theme_cubit.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import '../../auth/auth_cubit/auth_states.dart';
import '../../../api/config/di/di.dart';
import 'cubit/support_view_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final SupportViewModel _supportViewModel = getIt<SupportViewModel>();
  final _supportMessageController = TextEditingController();

  @override
  void dispose() {
    _supportMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final currentUser = authCubit.currentUser;

    return BlocProvider(
      create: (context) => _supportViewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () {
              // Optional: Handle back navigation
            },
          ),
          title: Text("My Profile", style: AppTextStyles.bold18White.copyWith(color: AppColors.primaryColor)),
          centerTitle: true,
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
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildProfileAvatar(currentUser),
              SizedBox(height: 16.h),
              Text(
                currentUser?.fullName ?? "User Name",
                style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30.h),
              _buildMenuSection(context, currentUser),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(dynamic user) {
    return Stack(
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
    );
  }

  Widget _buildMenuSection(BuildContext context, dynamic user) {
    final String role = (user?.role ?? 'patient').toLowerCase();
    final bool isDoctor = role == 'doctor';
    final bool isAdmin = role == 'admin';

    return Container(
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
          _buildMenuItem(
            icon: Icons.person_outline,
            label: "Profile",
            onTap: () {
              // Admin can now edit their profile like everyone else
              Navigator.pushNamed(context, AppRoutes.profileEditing);
            },
          ),
          const Divider(height: 1),
          if (isDoctor) ...[
            _buildMenuItem(
              icon: Icons.build_circle_outlined,
              label: "Managerial Staff",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.managerialStaff);
              },
            ),
            const Divider(height: 1),
          ],
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            label: "Privacy Policy",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.privacyPolicy);
            },
          ),
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            label: "Settings",
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          if (!isAdmin) ...[
            const Divider(height: 1),
            _buildMenuItem(
              icon: Icons.help_outline,
              label: "Help",
              onTap: () {
                _showSupportChat(context);
              },
            ),
          ],
          const Divider(height: 1),
          _buildMenuItem(
            icon: Icons.logout,
            label: "Logout",
            isLogout: true,
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : AppColors.primaryBlueSoft,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: isLogout ? Colors.red : AppColors.primaryColor, size: 22.r),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isLogout ? Colors.red : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isLogout ? Colors.red : AppColors.textTertiary, size: 20.r),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  void _showSupportChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (context) => BlocListener<SupportViewModel, SupportState>(
        bloc: _supportViewModel,
        listener: (context, state) {
          if (state is SupportSuccess) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Ticket sent successfully!"), backgroundColor: Colors.green),
            );
            _supportMessageController.clear();
          } else if (state is SupportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.support_agent, color: AppColors.primaryBlue),
                    SizedBox(width: 12.w),
                    Text("IT Support", style: AppTextStyles.titleLarge),
                  ],
                ),
                SizedBox(height: 8.h),
                Text("Describe your problem to the Admin", style: AppTextStyles.bodySmall),
                SizedBox(height: 24.h),
                TextField(
                  controller: _supportMessageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Message the IT team...",
                    filled: true,
                    fillColor: AppColors.backgroundPrimary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                BlocBuilder<SupportViewModel, SupportState>(
                  bloc: _supportViewModel,
                  builder: (context, state) {
                    final isLoading = state is SupportLoading;
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () {
                              if (_supportMessageController.text.isNotEmpty) {
                                _supportViewModel.sendTicket(_supportMessageController.text);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: AppColors.primaryGoldLight,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              isLoading ? "Sending..." : "Send Message",
                              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.primaryGoldLight),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
