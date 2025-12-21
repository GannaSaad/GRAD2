import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';

class AddRecordScreen extends StatefulWidget {
  final String patientName;
  const AddRecordScreen({super.key, required this.patientName});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _treatmentController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedSeverity = "Routine";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Add Medical Record", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(),
            SizedBox(height: 30.h),
            _buildSectionLabel("Treatment Type"),
            SizedBox(height: 12.h),
            CustomTextFormField(
              hintText: "e.g. Tooth Extraction, Root Canal",
              controller: _treatmentController,
              prefixIcon: const Icon(Icons.medical_services_outlined),
            ),
            SizedBox(height: 24.h),
            _buildSectionLabel("Diagnosis"),
            SizedBox(height: 12.h),
            CustomTextFormField(
              hintText: "Enter medical diagnosis",
              controller: _diagnosisController,
              maxLines: 2,
              prefixIcon: const Icon(Icons.assignment_outlined),
            ),
            SizedBox(height: 24.h),
            _buildSectionLabel("Case Severity"),
            SizedBox(height: 12.h),
            _buildSeveritySelector(),
            SizedBox(height: 24.h),
            _buildSectionLabel("Clinical Notes"),
            SizedBox(height: 12.h),
            CustomTextFormField(
              hintText: "Add detailed observations...",
              controller: _notesController,
              maxLines: 4,
              prefixIcon: const Icon(Icons.notes),
            ),
            SizedBox(height: 40.h),
            CustomElevatedButton(
              buttonText: "Save Record",
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Medical record added successfully!")),
                );
              },
              backgroundColor: AppColors.primaryColor,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          SizedBox(width: 12.w),
          Text(
            "Recording for: ${widget.patientName}",
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildSeveritySelector() {
    final severities = ["Routine", "Moderate", "Critical"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: severities.map((s) {
        bool isSelected = _selectedSeverity == s;
        return GestureDetector(
          onTap: () => setState(() => _selectedSeverity = s),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.borderSoft),
            ),
            child: Text(
              s,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
