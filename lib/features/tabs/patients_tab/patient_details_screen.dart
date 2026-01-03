import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientName;
  final String patientImage;

  const PatientDetailsScreen({
    super.key, 
    required this.patientName, 
    required this.patientImage,
  });

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
                  _buildSectionTitle("Medical Overview"),
                  SizedBox(height: 16.h),
                  _buildMedicalOverviewCard(),
                  SizedBox(height: 30.h),
                  _buildSectionTitle("Recent Visits"),
                  SizedBox(height: 16.h),
                  _buildVisitHistory(),
                  SizedBox(height: 30.h),
                  _buildSectionTitle("Notes"),
                  SizedBox(height: 16.h),
                  _buildNotesCard(),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addRecord, arguments: patientName);
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
          patientName,
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
                backgroundImage: AssetImage(patientImage),
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
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
    );
  }

  Widget _buildMedicalOverviewCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlueSoft),
      ),
      child: Column(
        children: [
          _buildOverviewRow("Allergies", "Penicillin, Latex", Colors.red),
          const Divider(height: 24),
          _buildOverviewRow("Condition", "Stable - Routine Followup", Colors.green),
          const Divider(height: 24),
          _buildOverviewRow("Insurance", "AXA Healthcare - Platinum", AppColors.primaryColor),
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

  Widget _buildVisitHistory() {
    return Column(
      children: [
        _buildVisitItem("Dental Scaling", "12 Dec 2024", "Success"),
        _buildVisitItem("Root Canal Phase 1", "20 Nov 2024", "Follow-up"),
      ],
    );
  }

  Widget _buildVisitItem(String title, String date, String tag) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: AppColors.primaryBlueSoft, shape: BoxShape.circle),
            child: Icon(Icons.history, color: AppColors.primaryColor, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(date, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: AppColors.backgroundPrimary, borderRadius: BorderRadius.circular(10.r)),
            child: Text(tag, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Light warm yellow for notes
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Text(
        "Patient experiences anxiety during long procedures. Prefers morning appointments. Ensure local anesthesia is fully effective before starting.",
        style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: Colors.orange.shade900),
      ),
    );
  }
}
