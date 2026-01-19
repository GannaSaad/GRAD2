import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';

class ReceptionistPatientDetailsScreen extends StatelessWidget {
  final String patientName;
  final String patientImage;
  final String treatment;
  final String time;

  const ReceptionistPatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientImage,
    required this.treatment,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Visit Overview", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
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
            _buildPatientHeader(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Clinical Schedule"),
            SizedBox(height: 12.h),
            _buildInfoCard(
              title: treatment,
              subtitle: "Scheduled for $time",
              icon: Icons.calendar_today_outlined,
            ),
            SizedBox(height: 32.h),
            _buildSectionHeader("Required Clinical Materials"),
            SizedBox(height: 12.h),
            _buildSuppliesList(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Doctor's Special Instructions"),
            SizedBox(height: 12.h),
            _buildNotesCard(),
            SizedBox(height: 40.h),
            CustomElevatedButton(
              buttonText: "Mark Arrived & Check-in",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$patientName has been checked in for surgery."),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              backgroundColor: AppColors.primaryBlue,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: AssetImage(patientImage),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientName, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                Text("Patient ID: #DX-2024-0012", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
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

  Widget _buildInfoCard({required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliesList() {
    final supplies = [
      {"name": "Anesthetic Vial", "qty": "1.8ml - 2% Lidocaine"},
      {"name": "Dental Mirror", "qty": "Standard #4"},
      {"name": "Latex Gloves", "qty": "Size M - 1 pair"},
    ];

    return Column(
      children: supplies.map((s) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s['name']!, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            Text(s['qty']!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Text(
        "Patient has high sensitivity. Pre-cool the anesthetic vial and ensure the high-suction tip is ready.",
        style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: Colors.orange.shade900),
      ),
    );
  }
}
