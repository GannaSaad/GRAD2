import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class AdminDoctorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const AdminDoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    // Mock patient data for this doctor
    final List<Map<String, String>> assignedPatients = [
      {"name": "Ahmed Mansour", "id": "PT-0012", "lastVisit": "20 Dec 2024", "status": "Stable"},
      {"name": "Layla Farid", "id": "PT-0045", "lastVisit": "18 Dec 2024", "status": "In Treatment"},
      {"name": "Yassin Kareem", "id": "PT-0088", "lastVisit": "15 Dec 2024", "status": "Completed"},
    ];

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
            _buildDoctorProfileSummary(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Credentials & Affiliations"),
            SizedBox(height: 12.h),
            _buildCredentialsCard(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Assigned Patients (${doctor['patients']})"),
            SizedBox(height: 16.h),
            _buildPatientsList(assignedPatients),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProfileSummary() {
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
            backgroundImage: AssetImage(doctor["image"]),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor["name"], style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                Text(doctor["field"], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                Text(doctor["location"], style: AppTextStyles.bodySmall),
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
          _buildCredRow(Icons.school_outlined, "Ph.D. in Specialized Medicine"),
          SizedBox(height: 12.h),
          _buildCredRow(Icons.business_outlined, "Affiliated with City General Hospital"),
          SizedBox(height: 12.h),
          _buildCredRow(Icons.verified_outlined, "Board Certified Specialist"),
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

  Widget _buildPatientsList(List<Map<String, String>> patients) {
    return Column(
      children: patients.map((p) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p["name"]!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text("ID: ${p["id"]} • Last Visit: ${p["lastVisit"]}", style: AppTextStyles.labelSmall),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _getStatusColor(p["status"]!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                p["status"]!,
                style: AppTextStyles.labelSmall.copyWith(
                  color: _getStatusColor(p["status"]!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Completed') return AppColors.success;
    if (status == 'In Treatment') return Colors.orange;
    return AppColors.primaryBlue;
  }
}
