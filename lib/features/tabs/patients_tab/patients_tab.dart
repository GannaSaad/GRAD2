import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/no_show_prediction.dart';
import 'cubit/patients_view_model.dart';

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  State<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PatientsViewModel _viewModel = getIt<PatientsViewModel>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _viewModel.getAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          title: Text("Clinical Management", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: BlocBuilder<PatientsViewModel, PatientsState>(
                builder: (context, state) {
                  if (state is PatientsLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                  } else if (state is PatientsFailure) {
                    return Center(child: Text(state.message));
                  } else if (state is PatientsSuccess) {
                    final complete = state.appointments.where((a) => a.status == 'Completed').toList();
                    final upcoming = state.appointments.where((a) => a.status == 'Pending' || a.status == 'Confirmed' || a.status == 'Rescheduled').toList();
                    final rescheduled = state.appointments.where((a) => a.status == 'Rescheduled').toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPatientsList(complete, state.predictions, "No completed clinical sessions."),
                        _buildPatientsList(upcoming, state.predictions, "No pending appointments."),
                        _buildPatientsList(rescheduled, state.predictions, "No rescheduled sessions."),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [Tab(text: "Complete"), Tab(text: "Upcoming"), Tab(text: "Rescheduled")],
      ),
    );
  }

  Widget _buildPatientsList(List<AppointmentEntity> appointments, Map<String, NoShowPrediction> predictions, String emptyMsg) {
    if (appointments.isEmpty) {
      return Center(child: Text(emptyMsg, style: AppTextStyles.bodyMedium));
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.r),
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final prediction = predictions[appt.patientId];
        return _buildPatientCard(appt, prediction);
      },
    );
  }

  Widget _buildPatientCard(AppointmentEntity appointment, NoShowPrediction? prediction) {
    final bool hasRealPhoto = appointment.patientImage != null && 
                             appointment.patientImage!.startsWith('http');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(appointment, hasRealPhoto),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.patientName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text(appointment.caseDescription, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    if (prediction != null) ...[
                      SizedBox(height: 8.h),
                      _buildNoShowChip(prediction.probability),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(DateFormat('dd MMM yyyy').format(appointment.date), style: AppTextStyles.labelSmall),
              const Spacer(),
              Icon(Icons.access_time, size: 16.r, color: AppColors.primaryBlue),
              SizedBox(width: 8.w),
              Text(appointment.time, style: AppTextStyles.labelSmall),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.patientDetails,
                      arguments: {'name': appointment.patientName, 'image': appointment.patientImage ?? ''}
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text("Case Details", style: AppTextStyles.buttonSmall),
                ),
              ),
              if (appointment.status != 'Completed') ...[
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    _viewModel.markAsComplete(appointment.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Session with ${appointment.patientName} marked as complete!")),
                    );
                  },
                  child: _buildActionIcon(Icons.check_circle_outline, Colors.green),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _viewModel.cancelAppointment(appointment.id),
                  child: _buildActionIcon(Icons.cancel_outlined, Colors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoShowChip(double probability) {
    Color color = Colors.green;
    if (probability > 70) color = Colors.red;
    else if (probability > 40) color = Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 12.r, color: color),
          SizedBox(width: 6.w),
          Text(
            "${probability.toStringAsFixed(1)}% No-Show Risk",
            style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppointmentEntity appointment, bool hasRealPhoto) {
    if (hasRealPhoto) {
      return CircleAvatar(
        radius: 28.r,
        backgroundImage: NetworkImage(appointment.patientImage!),
      );
    } else {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: AppColors.primaryBlueSoft,
        child: Text(
          appointment.patientName[0].toUpperCase(),
          style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 22.r),
    );
  }
}
