import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dentex_clean/api/config/di/di.dart';
import 'package:dentex_clean/core/core/utils/app_colors.dart';
import 'package:dentex_clean/core/core/utils/app_textstyles.dart';
import 'package:dentex_clean/domain/entities/user_entity.dart';
import 'cubit/admin_patients_view_model.dart';

class AdminPatientsTab extends StatefulWidget {
  const AdminPatientsTab({super.key});

  @override
  State<AdminPatientsTab> createState() => _AdminPatientsTabState();
}

class _AdminPatientsTabState extends State<AdminPatientsTab> {
  late AdminPatientsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AdminPatientsViewModel>();
    _viewModel.getAllPatients();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("Platform Patients", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: BlocBuilder<AdminPatientsViewModel, AdminPatientsState>(
          builder: (context, state) {
            if (state is AdminPatientsLoading) return const Center(child: CircularProgressIndicator());
            if (state is AdminPatientsFailure) return Center(child: Text(state.message));
            
            if (state is AdminPatientsSuccess) {
              // ENSURE ABSOLUTE UNIQUENESS AND AUTHENTICATION
              final Map<String, UserEntity> uniquePatientsMap = {};
              for (var p in state.patients) {
                // Only include real patients with valid emails, and map by email to force uniqueness
                if (p.email.isNotEmpty && p.role?.toLowerCase() == 'patient') {
                  uniquePatientsMap[p.email.toLowerCase()] = p;
                }
              }
              final List<UserEntity> patientsList = uniquePatientsMap.values.toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader(patientsList.length),
                  Expanded(
                    child: patientsList.isEmpty 
                      ? Center(child: Text("No authenticated patients found.", style: AppTextStyles.bodyMedium))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: patientsList.length,
                          itemBuilder: (context, index) => _buildPatientCard(context, patientsList[index]),
                        ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCountHeader(int count) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: Colors.white70),
          SizedBox(width: 12.w),
          Text(
            "$count Authenticated Patient Accounts",
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, UserEntity patient) {
    final String initials = (patient.fullName ?? "?").trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primaryBlueSoft,
            child: Text(initials, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 16.sp)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName ?? "Unnamed", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.medical_services_outlined, size: 14.r, color: AppColors.primaryGold),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        "Assigned to: ${patient.assignedDoctorName ?? "General Clinic User"}", 
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPatientDetails(context, patient),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(12.r)),
              child: const Icon(Icons.visibility_outlined, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(BuildContext context, UserEntity patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(color: AppColors.backgroundPrimary, borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text("Patient Profile Info", style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryBlue)),
            Text("Registration data provided by patient", style: AppTextStyles.labelSmall),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView(
                children: [
                  _buildDetailItem(Icons.person_outline, "Full Name", patient.fullName ?? "N/A"),
                  _buildDetailItem(Icons.email_outlined, "Auth Email", patient.email),
                  _buildDetailItem(Icons.phone_outlined, "Phone Number", patient.phoneNumber ?? "N/A"),
                  _buildDetailItem(Icons.cake_outlined, "Age", "${patient.age ?? 'N/A'} years"),
                  _buildDetailItem(Icons.wc_outlined, "Gender", patient.gender ?? "N/A"),
                  _buildDetailItem(Icons.warning_amber_rounded, "Disclosed Allergies", patient.allergies ?? "None"),
                  _buildDetailItem(Icons.shield_outlined, "Insurance Status", patient.medicalInsurance ?? "Not Provided"),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                child: Text("Close Details", style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(12.r)), child: Icon(icon, color: AppColors.primaryBlue, size: 20.r)),
          SizedBox(width: 16.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
}
