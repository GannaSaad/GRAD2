import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dentex_clean/api/config/di/di.dart';
import 'package:dentex_clean/core/core/utils/app_colors.dart';
import 'package:dentex_clean/core/core/utils/app_textstyles.dart';
import 'package:dentex_clean/domain/entities/user_entity.dart';
import 'package:dentex_clean/domain/entities/no_show_prediction.dart';
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
          title: Text("Patient List", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: BlocBuilder<AdminPatientsViewModel, AdminPatientsState>(
          builder: (context, state) {
            if (state is AdminPatientsLoading) return const Center(child: CircularProgressIndicator());
            if (state is AdminPatientsFailure) return Center(child: Text(state.message));
            
            if (state is AdminPatientsSuccess) {
              final List<UserEntity> patientsList = state.patients
                  .where((p) => p.role?.toLowerCase() == 'patient' && p.email.isNotEmpty)
                  .toList();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCountHeader(patientsList.length),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    child: Text("Patients", style: AppTextStyles.titleSmall),
                  ),
                  Expanded(
                    child: patientsList.isEmpty 
                      ? Center(child: Text("No patients found.", style: AppTextStyles.bodyMedium))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: patientsList.length,
                          itemBuilder: (context, index) {
                            final patient = patientsList[index];
                            final prediction = state.predictions[patient.uid];
                            return _buildPatientCard(context, patient, prediction);
                          },
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
          const Icon(Icons.analytics_outlined, color: Colors.white70),
          SizedBox(width: 12.w),
          Text(
            "$count Active Records Monitored",
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(BuildContext context, UserEntity patient, NoShowPrediction? prediction) {
    final String initials = (patient.fullName ?? "?").trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase();

    Color riskColor = Colors.grey;
    if (prediction != null) {
      if (prediction.probability > 70) riskColor = Colors.red;
      else if (prediction.probability > 30) riskColor = Colors.orange;
      else riskColor = Colors.green;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: AppColors.primaryBlueSoft,
            child: Text(initials, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14.sp)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.fullName ?? "Unnamed", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                if (prediction != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "${prediction.probability.toStringAsFixed(1)}% Risk (${prediction.riskLevel})",
                        style: AppTextStyles.labelSmall.copyWith(color: riskColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: 4.h),
                  Text("Calculating risk...", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPatientDetails(context, patient, prediction),
            icon: Icon(Icons.chevron_right, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(BuildContext context, UserEntity patient, NoShowPrediction? prediction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70,
        decoration: BoxDecoration(color: AppColors.backgroundPrimary, borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2.r)))),
            SizedBox(height: 24.h),
            Text("AI Diagnostic Summary", style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryBlue)),
            SizedBox(height: 16.h),
            if (prediction != null) _buildRiskSection(prediction),
            SizedBox(height: 24.h),
            _buildInfoRow(Icons.email_outlined, "Email", patient.email),
            _buildInfoRow(Icons.phone_outlined, "Phone", patient.phoneNumber ?? "N/A"),
            _buildInfoRow(Icons.medical_services_outlined, "Assigned Doctor", patient.assignedDoctorName ?? "None"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                child: const Text("Close", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSection(NoShowPrediction prediction) {
    Color riskColor = prediction.probability > 70 ? Colors.red : (prediction.probability > 30 ? Colors.orange : Colors.green);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("No-Show Probability", style: AppTextStyles.labelMedium),
          Text("${prediction.probability.toStringAsFixed(1)}%", style: AppTextStyles.headlineMedium.copyWith(color: riskColor, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text(
            "This prediction is generated based on historical appointment behavior and cancellation frequency.",
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
