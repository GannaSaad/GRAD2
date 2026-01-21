import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
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
  int? _selectedToothId;

  // Mock tooth-specific data
  final Map<int, Map<String, dynamic>> _toothData = {
    3: {
      'status': 'In Progress', 
      'diagnosis': 'Deep Caries', 
      'procedure': 'Pulpotomy', 
      'plan': 'Root Canal Therapy'
    },
    14: {
      'status': 'Completed', 
      'diagnosis': 'Vertical Fracture', 
      'procedure': 'Zirconia Crown', 
      'plan': 'Zirconia Crown' // Redundant: Procedure == Plan
    },
    22: {
      'status': 'In Progress', 
      'diagnosis': 'Gingival Recession', 
      'procedure': 'Scaling', 
      'plan': 'Gingival Graft'
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  SizedBox(height: 30.h),
                  
                  // 1. Medical Overview
                  _buildSectionTitle("Medical Overview"),
                  SizedBox(height: 16.h),
                  _buildMedicalOverviewCard(),
                  
                  SizedBox(height: 30.h),
                  
                  // 2. Current Prescriptions
                  _buildSectionTitle("Current Prescriptions"),
                  SizedBox(height: 16.h),
                  _buildRecordItem("Amoxicillin 500mg", "Dr. Hazem EL Beltagy", "Take 3 times daily after meals"),

                  SizedBox(height: 30.h),
                  
                  // 3. X-Rays & Imaging
                  _buildSectionTitle("X-Rays & Imaging"),
                  SizedBox(height: 16.h),
                  _buildImagingGrid(),
                  
                  SizedBox(height: 30.h),
                  
                  // 4. Dental Chart (Anatomical selection)
                  _buildSectionTitle("Dental Chart"),
                  SizedBox(height: 16.h),
                  JawChart(
                    selectedTooth: _selectedToothId,
                    onToothTap: (id) => setState(() => _selectedToothId = id),
                    toothData: _toothData,
                  ),
                  
                  if (_selectedToothId != null) ...[
                    SizedBox(height: 24.h),
                    _buildToothInfoPanel(),
                  ],
                  
                  SizedBox(height: 30.h),
                  
                  // 5. General Treatment Plan
                  _buildSectionTitle("Active Treatment Plan"),
                  SizedBox(height: 16.h),
                  _buildGeneralPlanCard(),
                  
                  SizedBox(height: 30.h),
                  
                  // 6. Clinical Visit History
                  _buildSectionTitle("Clinical Visit History"),
                  SizedBox(height: 16.h),
                  _buildVisitHistory(),
                  
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addRecord, arguments: widget.patientName);
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add_chart_outlined, color: Colors.white),
        label: const Text("Add Record", style: TextStyle(color: Colors.white)),
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
              child: CircleAvatar(
                radius: 50.r,
                backgroundImage: AssetImage(widget.patientImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem("Age", "28", Icons.cake_outlined),
        _buildStatItem("Gender", "Male", Icons.person_outline),
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

  Widget _buildGeneralPlanCard() {
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

  Widget _buildToothInfoPanel() {
    final data = _toothData[_selectedToothId];
    String status = data?['status'] ?? "No Record";
    Color statusColor = status == 'Completed' ? Colors.green.shade600 : Colors.red.shade600;

    final diagnosis = data?['diagnosis'] ?? "Not recorded";
    final procedure = data?['procedure'] ?? "Not recorded";
    final plan = data?['plan'] ?? "Not recorded";
    
    // SMART LOGIC: Remove Plan if Procedure is identical
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
