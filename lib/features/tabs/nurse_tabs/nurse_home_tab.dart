import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';

class NurseHomeTab extends StatelessWidget {
  const NurseHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              SizedBox(height: 24.h),
              _buildNurseProfileCard(),
              SizedBox(height: 30.h),
              _buildDailyTaskSummary(),
              SizedBox(height: 30.h),
              _buildSectionTitle("Today's Schedule"),
              SizedBox(height: 8.h),
              Text("Tap any patient to prepare clinical setup", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              SizedBox(height: 16.h),
              _buildScheduleList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back,",
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          "Nurse Assistant",
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildNurseProfileCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 40.r, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Assigned to: Dr. Hazem EL Beltagy",
                  style: AppTextStyles.titleSmall.copyWith(color: Colors.white),
                ),
                Text(
                  "Senior Dental Assistant",
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.r, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(
                      "Clinic A - Floor 2",
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTaskSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTaskCard("8", "Patients", Icons.people_outline, AppColors.primaryBlue),
        _buildTaskCard("3", "Requests", Icons.pending_actions, Colors.orange),
        _buildTaskCard("Low", "Inventory", Icons.inventory_2_outlined, Colors.red),
      ],
    );
  }

  Widget _buildTaskCard(String value, String label, IconData icon, Color color) {
    return Container(
      width: 105.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildScheduleList(BuildContext context) {
    final scheduleData = [
      {"name": "Ahmed Mansour", "task": "Tooth Record Update", "time": "09:00 AM", "room": "Room 1", "image": "assets/images/patient.jpeg"},
      {"name": "Layla Farid", "task": "X-Ray Preparation", "time": "10:30 AM", "room": "X-Ray Room", "image": "assets/images/patient1.jpeg"},
      {"name": "Yassin Kareem", "task": "Post-Op Check", "time": "01:00 PM", "room": "Room 1", "image": "assets/images/patient2.jpeg"},
    ];

    return Column(
      children: scheduleData.map((data) => _buildScheduleItem(context, data)).toList(),
    );
  }

  Widget _buildScheduleItem(BuildContext context, Map<String, String> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            Navigator.pushNamed(
              context, 
              AppRoutes.nursePatientDetails, 
              arguments: {'name': data["name"]!, 'image': data["image"]!}
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: AssetImage(data["image"]!),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["name"]!, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(data["task"]!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(data["time"]!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(data["room"]!, style: AppTextStyles.labelSmall.copyWith(fontSize: 9.sp, color: AppColors.primaryBlue)),
                    ),
                  ],
                ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.r, color: AppColors.primaryGold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
