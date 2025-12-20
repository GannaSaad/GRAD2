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
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Medical Records", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          _buildRecordCategory("Prescriptions", Icons.medication_outlined, [
            _buildRecordItem("Amoxicillin 500mg", "Dr. Hazem EL Beltagy", "12 Dec 2024"),
            _buildRecordItem("Paracetamol 1g", "Dr. Lina Fathy", "05 Dec 2024"),
          ]),
          SizedBox(height: 24.h),
          _buildRecordCategory("Test Results", Icons.assignment_outlined, [
            _buildRecordItem("Dental X-Ray (Full)", "Dentix Lab", "10 Dec 2024"),
            _buildRecordItem("Blood Test", "Central Lab", "01 Nov 2024"),
          ]),
          SizedBox(height: 24.h),
          _buildRecordCategory("Treatment Plans", Icons.history_edu_outlined, [
            _buildRecordItem("Root Canal Phase 1", "Dr. Mariam Hassan", "20 Nov 2024"),
          ]),
        ],
      ),
    );
  }

  Widget _buildRecordCategory(String title, IconData icon, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24.r),
            SizedBox(width: 12.w),
            Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 12.h),
        ...items,
      ],
    );
  }

  Widget _buildRecordItem(String title, String provider, String date) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: 4.h),
                Text(provider, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: AppTextStyles.labelSmall),
              SizedBox(height: 8.h),
              Icon(Icons.download_outlined, color: AppColors.primaryColor, size: 20.r),
            ],
          ),
        ],
      ),
    );
  }
}
