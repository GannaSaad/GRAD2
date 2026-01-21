import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Medical Records", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Medical Overview"),
            SizedBox(height: 16.h),
            _buildMedicalOverviewCard(),
            
            SizedBox(height: 30.h),
            _buildSectionTitle("Current Prescriptions"),
            SizedBox(height: 16.h),
            _buildRecordItem("Amoxicillin 500mg", "Dr. Hazem EL Beltagy", "Take 3 times daily after meals"),

            SizedBox(height: 30.h),
            _buildSectionTitle("X-Rays & Imaging"),
            SizedBox(height: 16.h),
            _buildImagingGrid(),

            SizedBox(height: 30.h),
            _buildSectionTitle("Active Treatment Plan"),
            SizedBox(height: 16.h),
            _buildTreatmentPlanCard(),

            SizedBox(height: 30.h),
            _buildSectionTitle("Clinical Visit History"),
            SizedBox(height: 16.h),
            _buildVisitHistory(),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildMedicalOverviewCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlueLight),
      ),
      child: Column(
        children: [
          _buildOverviewRow("Allergies", "Penicillin, Latex", Colors.red),
          const Divider(height: 24),
          _buildOverviewRow("Condition", "Stable", Colors.green),
          const Divider(height: 24),
          _buildOverviewRow("Insurance", "AXA Platinum", AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRecordItem(String title, String provider, String instruction) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: const BoxDecoration(color: AppColors.primaryBlueLight, shape: BoxShape.circle),
            child: const Icon(Icons.medication_outlined, color: AppColors.primaryBlue, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(provider, style: AppTextStyles.labelSmall),
                SizedBox(height: 4.h),
                Text(instruction, style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.r,
      crossAxisSpacing: 12.r,
      children: [
        _buildImageTile("Panoramic X-Ray", Icons.panorama_horizontal),
        _buildImageTile("Intraoral Root", Icons.center_focus_strong),
      ],
    );
  }

  Widget _buildImageTile(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 32.r),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTreatmentPlanCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(
        "Phase 1: Routine scaling and hygiene maintenance. Phase 2: Crown restoration for Tooth #14.",
        style: AppTextStyles.bodySmall,
      ),
    );
  }

  Widget _buildVisitHistory() {
    return Column(
      children: [
        _buildHistoryItem("Routine Checkup", "12 Dec 2024", "Success", Colors.green),
        _buildHistoryItem("Surgical Extraction", "20 Nov 2024", "Success", Colors.green),
      ],
    );
  }

  Widget _buildHistoryItem(String title, String date, String status, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              Text(date, style: AppTextStyles.labelSmall),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
            child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
