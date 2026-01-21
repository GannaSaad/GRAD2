import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';

class NursePatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final String patientImage;

  const NursePatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientImage,
  });

  @override
  State<NursePatientDetailsScreen> createState() => _NursePatientDetailsScreenState();
}

class _NursePatientDetailsScreenState extends State<NursePatientDetailsScreen> {
  // Advanced inventory picking state for the nurse assistant
  final List<Map<String, dynamic>> _clinicalSupplies = [
    {"name": "Latex Gloves", "measure": "Size M - 1 pair", "picked": false},
    {"name": "Dental Mirror", "measure": "Standard #4", "picked": false},
    {"name": "Composite Resin", "measure": "2g Capsule - Shade A2", "picked": false},
    {"name": "Anesthetic Vial", "measure": "1.8ml - 2% Lidocaine", "picked": false},
    {"name": "High-Volume Suction", "measure": "Single-use tip", "picked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Clinical Preparation", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
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
            _buildSectionHeader("Scheduled Treatment"),
            SizedBox(height: 12.h),
            _buildTreatmentCard(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Materials & Tools Checklist"),
            SizedBox(height: 8.h),
            Text("Tap items to pick from inventory", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            SizedBox(height: 16.h),
            _buildMaterialsChecklist(),
            SizedBox(height: 32.h),
            _buildSectionHeader("Doctor's Special Instructions"),
            SizedBox(height: 12.h),
            _buildNotesCard(),
            SizedBox(height: 40.h),
            CustomElevatedButton(
              buttonText: "Confirm Readiness",
              onPressed: _isReady() ? () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("All materials picked. Clinical setup is ready!")),
                );
              } : null,
              backgroundColor: _isReady() ? AppColors.primaryBlue : AppColors.borderMedium,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  bool _isReady() => _clinicalSupplies.every((s) => s['picked']);

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: AssetImage(widget.patientImage),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patientName, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              Text("Patient ID: #DX-2024-0012", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildTreatmentCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlueLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_information_outlined, color: AppColors.primaryBlue),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Root Canal Therapy", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("Room 04 • Scheduled for 10:30 AM", style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsChecklist() {
    return Column(
      children: _clinicalSupplies.map((item) {
        bool isPicked = item['picked'];
        return GestureDetector(
          onTap: () => setState(() => item['picked'] = !isPicked),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isPicked ? AppColors.successLight : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isPicked ? AppColors.success : AppColors.borderSoft),
            ),
            child: Row(
              children: [
                Icon(
                  isPicked ? Icons.check_circle : Icons.inventory_2_outlined,
                  color: isPicked ? AppColors.success : AppColors.primaryBlue,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(item['measure'], style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (isPicked) 
                  Text("PICKED", style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
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
