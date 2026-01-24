import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_assets.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import 'cubit/patient_home_view_model.dart';

class PatientHomeTab extends StatefulWidget {
  final VoidCallback onBookDoctorTap;
  final VoidCallback onAppointmentsTap;
  final VoidCallback onAssistantTap;

  const PatientHomeTab({
    super.key, 
    required this.onBookDoctorTap,
    required this.onAppointmentsTap,
    required this.onAssistantTap,
  });

  @override
  State<PatientHomeTab> createState() => _PatientHomeTabState();
}

class _PatientHomeTabState extends State<PatientHomeTab> {
  final PatientHomeViewModel _viewModel = getIt<PatientHomeViewModel>();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDynamicGreetingHeader(),
                SizedBox(height: 24.h),

                _buildActionCard(
                  onTap: widget.onBookDoctorTap,
                  icon: Icons.calendar_month_outlined,
                  title: "Looking For a Doctor?",
                  subtitle: "Find and book a specialist",
                  iconBgColor: const Color(0xFFE8F0FF),
                  iconColor: AppColors.primaryBlue,
                ),
                SizedBox(height: 12.h),
                _buildActionCard(
                  onTap: widget.onAssistantTap,
                  imagePath: AppImages.shagyLogo,
                  title: "SHAGY",
                  subtitle: "Describe symptoms and get instant guidance",
                  isImage: true,
                ),
                SizedBox(height: 12.h),
                _buildActionCard(
                  onTap: widget.onAppointmentsTap,
                  icon: Icons.event_note_outlined,
                  title: "My Appointments",
                  subtitle: "View, reschedule, or cancel visits",
                  iconBgColor: const Color(0xFFF0FDF4),
                  iconColor: Colors.green,
                ),
                SizedBox(height: 30.h),

                Text("Quick Health Snapshot", style: AppTextStyles.titleLarge),
                SizedBox(height: 16.h),
                BlocBuilder<PatientHomeViewModel, PatientHomeState>(
                  builder: (context, state) {
                    String allergyText = "None";
                    if (state is PatientHomeSuccess) {
                      allergyText = (state.user.allergies != null && state.user.allergies!.isNotEmpty)
                          ? state.user.allergies!
                          : "None";
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSnapshotCard(Icons.warning_amber_rounded, "Allergies", allergyText, Colors.orange),
                        _buildSnapshotCard(Icons.shield_outlined, "Insurance", "Active", Colors.blue),
                        _buildSnapshotCard(Icons.history, "History", "Updated", Colors.green),
                      ],
                    );
                  },
                ),
                SizedBox(height: 30.h),

                Text("Medical Records", style: AppTextStyles.titleLarge),
                SizedBox(height: 16.h),
                _buildMedicalRecordsCard(context),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicGreetingHeader() {
    return BlocBuilder<PatientHomeViewModel, PatientHomeState>(
      builder: (context, state) {
        String greeting = "Welcome back";
        String nextAppointmentText = "No upcoming visits";
        bool hasUpcoming = false;

        if (state is PatientHomeSuccess) {
          greeting = "${state.greeting} 👋";
          final now = DateTime.now();
          final upcoming = state.appointments
              .where((a) => a.date.isAfter(now) && a.status != 'Cancelled')
              .toList();
          
          if (upcoming.isNotEmpty) {
            upcoming.sort((a, b) => a.date.compareTo(b.date));
            final next = upcoming.first;
            final dateStr = DateUtils.isSameDay(next.date, now) 
                ? "Today" 
                : DateUtils.isSameDay(next.date, now.add(const Duration(days: 1)))
                    ? "Tomorrow"
                    : DateFormat('dd MMM').format(next.date);
            nextAppointmentText = "Next appointment: $dateStr at ${next.time}";
            hasUpcoming = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                greeting,
                style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: hasUpcoming ? AppColors.primaryBlueSoft : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, size: 18.r, color: hasUpcoming ? AppColors.primaryBlue : Colors.grey),
                  SizedBox(width: 8.w),
                  Text(
                    nextAppointmentText,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: hasUpcoming ? AppColors.primaryBlue : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCard({
    IconData? icon,
    String? imagePath,
    required String title,
    required String subtitle,
    Color? iconBgColor,
    Color? iconColor,
    bool isImage = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
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
            Container(
              height: 48.r,
              width: 48.r,
              decoration: BoxDecoration(
                color: isImage ? Colors.transparent : (iconBgColor ?? AppColors.primaryBlueSoft),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: isImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(imagePath!, fit: BoxFit.cover),
                    )
                  : Icon(icon, color: iconColor ?? AppColors.primaryBlue, size: 24.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotCard(IconData icon, String label, String value, Color iconColor) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 28.r),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyles.labelSmall),
          SizedBox(height: 4.h),
          Text(
            value, 
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueSoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.folder_shared_outlined, color: AppColors.primaryBlue, size: 30.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Access Your Records", style: AppTextStyles.titleMedium),
                    Text(
                      "View medical history, prescriptions, and test results",
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomElevatedButton(
            buttonText: "View All Records",
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.medicalRecords);
            },
            backgroundColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}
