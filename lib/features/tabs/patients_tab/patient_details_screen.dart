import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
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
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))),
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
                          _buildMedicalOverviewCard(),
                          
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
                          
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
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
        background: Container(color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Age", "28", Icons.cake_outlined),
        _buildStatItem("Gender", "Female", Icons.person_outline),
        _buildStatItem("Blood", "A+", Icons.bloodtype_outlined),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
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
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          _buildOverviewRow("Allergies", "Penicillin", Colors.red),
          const Divider(height: 24),
          _buildOverviewRow("Condition", "Healthy", Colors.green),
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

  Widget _buildImagingGrid(List<MedicalRecordEntity> records) {
    final List<String> allImages = [];
    for (var record in records) {
      if (record.panoramicImages != null) allImages.addAll(record.panoramicImages!);
      if (record.intraoralImages != null) allImages.addAll(record.intraoralImages!);
    }

    if (allImages.isEmpty) {
      return Center(child: Text("No clinical images found.", style: AppTextStyles.bodySmall));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allImages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.r,
        crossAxisSpacing: 12.r,
      ),
      itemBuilder: (context, index) => _buildActualImageTile(allImages[index]),
    );
  }

  Widget _buildActualImageTile(String url) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildToothInfoPanel(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();
    
    String status = data['status'] ?? "No Record";
    Color statusColor = status == 'Completed' ? Colors.green : Colors.red;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tooth #$_selectedToothId Analysis", style: AppTextStyles.titleSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Text("Diagnosis: ${data['diagnosis'] ?? 'N/A'}", style: AppTextStyles.bodySmall),
          Text("Procedure: ${data['procedure'] ?? 'N/A'}", style: AppTextStyles.bodySmall),
          Text("Status: $status", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }
}
