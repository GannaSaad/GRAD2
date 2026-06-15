import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../../widgets/widgets/custom_text_form_field.dart';
import 'cubit/add_record_view_model.dart';
import 'widgets/jaw_chart.dart';

class ToothRecordData {
  String diagnosis;
  String procedure;
  String plan;
  String status;

  ToothRecordData({
    this.diagnosis = "",
    this.procedure = "",
    this.plan = "",
    this.status = "In Progress",
  });
}

class AddRecordScreen extends StatefulWidget {
  final String patientName;
  const AddRecordScreen({super.key, required this.patientName});

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final AddRecordViewModel _viewModel = getIt<AddRecordViewModel>();
  final ImagePicker _picker = ImagePicker();

  // Image files
  final List<File> _panoramicImages = [];
  final List<File> _intraoralImages = [];

  // Multi-tooth data storage
  final Map<int, ToothRecordData> _toothRecords = {};
  int? _selectedToothId;

  // Controllers (linked to the currently selected tooth)
  final _toothDiagnosisController = TextEditingController();
  final _toothProcedureController = TextEditingController();
  final _toothPlanController = TextEditingController();

  // General controllers
  final _generalNotesController = TextEditingController();
  final _prescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to controller changes to update the map in real-time
    _toothDiagnosisController.addListener(_updateCurrentToothData);
    _toothProcedureController.addListener(_updateCurrentToothData);
    _toothPlanController.addListener(_updateCurrentToothData);
  }

  void _updateCurrentToothData() {
    if (_selectedToothId != null) {
      final data = _toothRecords[_selectedToothId!] ??= ToothRecordData();
      data.diagnosis = _toothDiagnosisController.text;
      data.procedure = _toothProcedureController.text;
      data.plan = _toothPlanController.text;
    }
  }

  void _onToothSelected(int id) {
    setState(() {
      _selectedToothId = id;
      final data = _toothRecords[id] ??= ToothRecordData();

      // Temporarily remove listeners to avoid triggering _updateCurrentToothData while setting text
      _toothDiagnosisController.removeListener(_updateCurrentToothData);
      _toothProcedureController.removeListener(_updateCurrentToothData);
      _toothPlanController.removeListener(_updateCurrentToothData);

      _toothDiagnosisController.text = data.diagnosis;
      _toothProcedureController.text = data.procedure;
      _toothPlanController.text = data.plan;

      _toothDiagnosisController.addListener(_updateCurrentToothData);
      _toothProcedureController.addListener(_updateCurrentToothData);
      _toothPlanController.addListener(_updateCurrentToothData);
    });
  }

  Future<void> _pickImages(bool isPanoramic) async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        if (isPanoramic) {
          _panoramicImages.addAll(images.map((e) => File(e.path)));
        } else {
          _intraoralImages.addAll(images.map((e) => File(e.path)));
        }
      });
    }
  }

  @override
  void dispose() {
    _toothDiagnosisController.dispose();
    _toothProcedureController.dispose();
    _toothPlanController.dispose();
    _generalNotesController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
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
        body: BlocListener<AddRecordViewModel, AddRecordState>(
          listener: (context, state) {
            if (state is AddRecordSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Medical record saved successfully!")),
              );
            } else if (state is AddRecordFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
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
                  onToothTap: _onToothSelected,
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
                  child: BlocBuilder<AddRecordViewModel, AddRecordState>(
                    builder: (context, state) {
                      final bool isLoading = state is AddRecordLoading;
                      return CustomElevatedButton(
                        buttonText: isLoading ? "Saving..." : "Save Complete Record",
                        onPressed: isLoading ? null : () {
                          _viewModel.saveRecord(
                            patientName: widget.patientName,
                            toothId: _selectedToothId,
                            toothDiagnosis: _toothDiagnosisController.text,
                            toothProcedure: _toothProcedureController.text,
                            toothPlan: _toothPlanController.text,
                            treatmentStatus: _selectedToothId != null ? _toothRecords[_selectedToothId!]!.status : null,
                            prescription: _prescriptionController.text,
                            generalNotes: _generalNotesController.text,
                            panoramicImages: _panoramicImages,
                            intraoralImages: _intraoralImages,
                          );
                        },
                        backgroundColor: isLoading ? AppColors.grayColor : AppColors.primaryColor,
                      );
                    },
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
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
    final currentStatus = _toothRecords[_selectedToothId!]?.status ?? "In Progress";
    bool isSelected = currentStatus == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _toothRecords[_selectedToothId!]!.status = status;
        }),
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
          _buildUploadCard("Panoramic X-Ray", Icons.panorama_horizontal_select, _panoramicImages, () => _pickImages(true)),
          SizedBox(height: 12.h),
          _buildUploadCard("Intraoral X-Ray", Icons.center_focus_strong_outlined, _intraoralImages, () => _pickImages(false)),
        ],
      ),
    );
  }

  Widget _buildUploadCard(String label, IconData icon, List<File> selectedImages, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTextStyles.bodyMedium),
                      if (selectedImages.isNotEmpty)
                        Text("${selectedImages.length} images selected", style: AppTextStyles.labelSmall.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Icon(
                    selectedImages.isNotEmpty ? Icons.add_a_photo : Icons.cloud_upload_outlined,
                    color: AppColors.primaryBlue,
                    size: 24.r
                ),
              ],
            ),
          ),
        ),
        if (selectedImages.isNotEmpty) ...[
          SizedBox(height: 8.h),
          SizedBox(
            height: 60.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(selectedImages[index], width: 60.w, height: 60.h, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => selectedImages.removeAt(index)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Icon(Icons.close, size: 16.r, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}