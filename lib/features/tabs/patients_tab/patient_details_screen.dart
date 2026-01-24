import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/medical_record_entity.dart';
import 'cubit/patient_details_view_model.dart';
import 'widgets/jaw_chart.dart';

class PatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final String patientImage;

  const PatientDetailsScreen({
    super.key, 
    required this.patientName, 
    required this.patientImage,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late PatientDetailsViewModel _viewModel;
  int? _selectedToothId;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PatientDetailsViewModel>();
    _viewModel.getMedicalRecords(widget.patientName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: BlocBuilder<PatientDetailsViewModel, PatientDetailsState>(
          builder: (context, state) {
            List<MedicalRecordEntity> records = [];
            if (state is PatientDetailsSuccess) {
              records = state.records;
            }

            final Map<int, Map<String, dynamic>> toothDataMap = {};
            for (var record in records) {
              if (record.toothId != null) {
                toothDataMap[record.toothId!] = {
                  'status': record.treatmentStatus,
                  'diagnosis': record.toothDiagnosis,
                  'procedure': record.toothProcedure,
                  'plan': record.toothPlan,
                };
              }
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(context),
                if (state is PatientDetailsLoading)
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                if (state is PatientDetailsFailure)
                  SliverFillRemaining(child: Center(child: Text(state.message))),
                if (state is PatientDetailsSuccess || state is PatientDetailsInitial)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickStats(),
                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("Medical Overview"),
                          SizedBox(height: 16.h),
                          _buildMedicalOverviewCard(records),
                          
                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("Current Prescriptions"),
                          SizedBox(height: 16.h),
                          _buildPrescriptionsList(records),

                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("X-Rays & Imaging"),
                          SizedBox(height: 16.h),
                          _buildImagingGrid(records),
                          
                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("Dental Chart"),
                          SizedBox(height: 16.h),
                          JawChart(
                            selectedTooth: _selectedToothId,
                            onToothTap: (id) => setState(() => _selectedToothId = id),
                            toothData: toothDataMap,
                          ),
                          
                          if (_selectedToothId != null) ...[
                            SizedBox(height: 24.h),
                            _buildToothInfoPanel(toothDataMap[_selectedToothId!]),
                          ],
                          
                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("Active Treatment Plan"),
                          SizedBox(height: 16.h),
                          _buildGeneralPlanCard(records),
                          
                          SizedBox(height: 30.h),
                          
                          _buildSectionTitle("Clinical Visit History"),
                          SizedBox(height: 16.h),
                          _buildVisitHistory(records),
                          
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addRecord, arguments: widget.patientName);
          },
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Icons.add_chart_outlined, color: Colors.white),
          label: const Text("Add Record", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          widget.patientName,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(color: AppColors.primaryColor),
            Positioned(
              top: 60.h,
              child: _buildAvatar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final bool hasRealPhoto = widget.patientImage.startsWith('http');
    
    if (hasRealPhoto) {
      return CircleAvatar(
        radius: 50.r,
        backgroundImage: NetworkImage(widget.patientImage),
      );
    } else {
      final String initials = widget.patientName.isNotEmpty 
          ? widget.patientName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
          : "?";
          
      return CircleAvatar(
        radius: 50.r,
        backgroundColor: AppColors.primaryBlueSoft,
        child: Text(
          initials,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 32.sp,
          ),
        ),
      );
    }
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Age", "28", Icons.cake_outlined),
        _buildStatItem("Gender", "female", Icons.person_outline),
        _buildStatItem("Blood", "A+", Icons.bloodtype_outlined),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 20.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildMedicalOverviewCard(List<MedicalRecordEntity> records) {
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

  Widget _buildPrescriptionsList(List<MedicalRecordEntity> records) {
    final prescriptions = records.where((r) => r.prescription != null && r.prescription!.isNotEmpty).toList();
    if (prescriptions.isEmpty) {
      return Center(child: Text("No prescriptions recorded", style: AppTextStyles.bodySmall));
    }

    return Column(
      children: prescriptions.map((r) => _buildRecordItem(r.prescription!, "Dentex Clinic", "As recorded on ${r.createdAt.day}/${r.createdAt.month}")).toList(),
    );
  }

  Widget _buildRecordItem(String title, String provider, String instruction) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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

  Widget _buildImagingGrid(List<MedicalRecordEntity> records) {
    final List<String> panoramic = [];
    final List<String> intraoral = [];
    for (var record in records) {
      if (record.panoramicImages != null) panoramic.addAll(record.panoramicImages!);
      if (record.intraoralImages != null) intraoral.addAll(record.intraoralImages!);
    }

    if (panoramic.isEmpty && intraoral.isEmpty) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12.r,
        crossAxisSpacing: 12.r,
        children: [
          _buildImageTilePlaceholder("Panoramic X-Ray", Icons.panorama_horizontal),
          _buildImageTilePlaceholder("Intraoral Root", Icons.center_focus_strong),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (panoramic.isNotEmpty) ...[
          Text("Panoramic", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: panoramic.length,
              itemBuilder: (context, index) => _buildActualImageTile(panoramic[index]),
            ),
          ),
          SizedBox(height: 16.h),
        ],
        if (intraoral.isNotEmpty) ...[
          Text("Intraoral", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: intraoral.length,
              itemBuilder: (context, index) => _buildActualImageTile(intraoral[index]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActualImageTile(String base64Image) {
    return Container(
      margin: EdgeInsets.only(right: 12.w),
      width: 120.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.memory(
          base64Decode(base64Image),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error)),
        ),
      ),
    );
  }

  Widget _buildImageTilePlaceholder(String label, IconData icon) {
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

  Widget _buildGeneralPlanCard(List<MedicalRecordEntity> records) {
    final plans = records.where((r) => r.toothPlan != null && r.toothPlan!.isNotEmpty).toList();
    String planText = "No active treatment plan recorded.";
    if (plans.isNotEmpty) {
      planText = plans.map((p) => "Tooth #${p.toothId}: ${p.toothPlan}").join(". ");
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Text(planText, style: AppTextStyles.bodySmall),
    );
  }

  Widget _buildVisitHistory(List<MedicalRecordEntity> records) {
    if (records.isEmpty) {
      return Center(child: Text("No visits recorded", style: AppTextStyles.bodySmall));
    }
    return Column(
      children: records.map((r) => _buildHistoryItem(
        r.toothProcedure ?? "Consultation", 
        "${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year}", 
        r.treatmentStatus ?? "Success", 
        r.treatmentStatus == 'Completed' ? Colors.green : Colors.blue
      )).toList(),
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

  Widget _buildToothInfoPanel(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();
    
    String status = data['status'] ?? "No Record";
    Color statusColor = status == 'Completed' ? Colors.green.shade600 : Colors.red.shade600;

    final diagnosis = data['diagnosis'] ?? "Not recorded";
    final procedure = data['procedure'] ?? "Not recorded";
    final plan = data['plan'] ?? "Not recorded";
    
    final bool hidePlan = procedure == plan;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              SizedBox(width: 8.w),
              Text("Tooth #$_selectedToothId Analysis", style: AppTextStyles.titleSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12.h),
          _buildInfoRow("Diagnosis", diagnosis),
          _buildInfoRow("Last Procedure", procedure),
          if (!hidePlan) _buildInfoRow("Next Phase", plan),
          _buildInfoRow("Current Status", status),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}
