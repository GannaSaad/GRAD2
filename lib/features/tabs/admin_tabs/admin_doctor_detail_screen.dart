import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class AdminDoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const AdminDoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Provide safe defaults to prevent 'Null' is not a subtype of 'String' crash
    final String name = doctor['name'] ?? "Unknown Doctor";
    final String field = doctor['field'] ?? doctor['specialty'] ?? "General Dentist";
    final String location = doctor['location'] ?? "Maadi, Cairo";
    final String patients = doctor['patients']?.toString() ?? "0";
    final String image = doctor['image'] ?? "assets/images/doctor.jpg";

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Doctor Management", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDoctorProfileSummary(name, field, location, image),
            SizedBox(height: 32.h),
            _buildSectionHeader("Credentials & Affiliations"),
            SizedBox(height: 12.h),
            _buildCredentialsCard(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Clinical Activity Summary"),
            SizedBox(height: 16.h),
            _buildStatsRow(patients),
            SizedBox(height: 32.h),
            _buildSectionHeader("Account Management"),
            SizedBox(height: 12.h),
            _buildManagementActions(context, name),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfileSummary(String name, String field, String location, String image) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: AppColors.primaryBlueSoft,
            child: Icon(Icons.person, size: 40.r, color: AppColors.primaryBlue),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                Text(field, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                Text(location, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildCredentialsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCredRow(Icons.school_outlined, "Verified Professional Degree"),
          SizedBox(height: 12.h),
          _buildCredRow(Icons.verified_user_outlined, "Medical License Valid"),
          SizedBox(height: 12.h),
          _buildCredRow(Icons.verified_outlined, "Dentix Premium Network Member"),
        ],
      ),
    );
  }

  Widget _buildCredRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primaryBlue),
        SizedBox(width: 12.w),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildStatsRow(String patientCount) {
    return Row(
      children: [
        _buildStatItem("Total Patients", patientCount, Icons.people_outline, Colors.blue),
        SizedBox(width: 16.w),
        _buildStatItem("Revenue", "Live Sync", Icons.monetization_on_outlined, Colors.green),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(height: 8.h),
            Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementActions(BuildContext context, String name) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
          title: const Text("Edit Permissions"),
          onTap: () {},
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          tileColor: AppColors.cardBackground,
        ),
        SizedBox(height: 8.h),
        ListTile(
          leading: const Icon(Icons.block_flipped, color: Colors.red),
          title: const Text("Suspend Account", style: TextStyle(color: Colors.red)),
          onTap: () {
            _showDeleteConfirm(context, name);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          tileColor: Colors.red.withOpacity(0.05),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Suspension"),
        content: Text("Are you sure you want to suspend Dr. $name's clinical access?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
