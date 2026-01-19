import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import 'widgets/jaw_chart.dart';

class AddRecordScreen extends StatefulWidget {
  final String patientName;
  const AddRecordScreen({super.key, required this.patientName});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  // Tooth-specific controllers
  final _toothDiagnosisController = TextEditingController();
  final _toothProcedureController = TextEditingController();
  final _toothPlanController = TextEditingController();
  String _treatmentStatus = "In Progress"; 
  int? _selectedToothId;

  // General controllers
  final _generalNotesController = TextEditingController();
  final _prescriptionController = TextEditingController();

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
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(),
            SizedBox(height: 30.h),
            
            _buildSectionLabel("Select Tooth from Jaw"),
            SizedBox(height: 16.h),
            JawChart(
              selectedTooth: _selectedToothId,
              onToothTap: (id) => setState(() => _selectedToothId = id),
            ),
            
            if (_selectedToothId != null) ...[
              SizedBox(height: 30.h),
              _buildSectionLabel("Tooth #$_selectedToothId Details"),
              SizedBox(height: 16.h),
              
              _buildStatusSelector(),
              SizedBox(height: 20.h),
              
              _buildInputContainer(
                child: CustomTextFormField(
                  hintText: "Tooth Diagnosis",
                  controller: _toothDiagnosisController,
                  prefixIcon: const Icon(Icons.assignment_outlined),
                ),
              ),
              SizedBox(height: 16.h),
              
              _buildInputContainer(
                child: CustomTextFormField(
                  hintText: "Procedure Performed",
                  controller: _toothProcedureController,
                  prefixIcon: const Icon(Icons.medical_services_outlined),
                ),
              ),
              SizedBox(height: 16.h),
              
              _buildInputContainer(
                child: CustomTextFormField(
                  hintText: "Specific Treatment Plan",
                  controller: _toothPlanController,
                  prefixIcon: const Icon(Icons.next_plan_outlined),
                ),
              ),
            ],

            const Divider(height: 60),
            
            _buildSectionLabel("General Information"),
            SizedBox(height: 16.h),
            
            _buildSectionLabelSmall("Prescriptions"),
            SizedBox(height: 12.h),
            _buildInputContainer(
              child: CustomTextFormField(
                hintText: "e.g. Amoxicillin 500mg - 3 times daily",
                controller: _prescriptionController,
                maxLines: 2,
                prefixIcon: const Icon(Icons.medication_outlined),
              ),
            ),

            SizedBox(height: 24.h),
            _buildSectionLabelSmall("X-Rays & Imaging"),
            SizedBox(height: 12.h),
            _buildImagingSection(),
            
            SizedBox(height: 24.h),
            _buildSectionLabelSmall("General Clinical Notes"),
            SizedBox(height: 12.h),
            _buildInputContainer(
              child: CustomTextFormField(
                hintText: "Add global observations for this visit...",
                controller: _generalNotesController,
                maxLines: 4,
                prefixIcon: const Icon(Icons.notes),
              ),
            ),
            
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomElevatedButton(
                buttonText: "Save Complete Record",
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Medical record saved successfully!")),
                  );
                },
                backgroundColor: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: child,
    );
  }

  Widget _buildStatusSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          _buildStatusChip("In Progress", Colors.red),
          SizedBox(width: 16.w),
          _buildStatusChip("Completed", Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color activeColor) {
    bool isSelected = _treatmentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _treatmentStatus = status),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSelected ? activeColor : AppColors.borderSoft),
          ),
          child: Center(
            child: Text(
              status,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(label, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSectionLabelSmall(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Text(label, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }

  Widget _buildImagingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          _buildUploadCard("Panoramic X-Ray", Icons.panorama_horizontal_select),
          SizedBox(height: 12.h),
          _buildUploadCard("Intraoral X-Ray", Icons.center_focus_strong_outlined),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Icon(Icons.cloud_upload_outlined, color: AppColors.primaryBlue, size: 24.r),
        ],
      ),
    );
  }
}
