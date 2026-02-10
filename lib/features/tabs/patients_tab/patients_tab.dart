import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/appointment_entity.dart';
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Patients", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
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
                        _buildPatientsList(complete, "No completed visits"),
                        _buildPatientsList(upcoming, "No upcoming appointments"),
                        _buildPatientsList(rescheduled, "No rescheduled visits"),
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
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [Tab(text: "Complete"), Tab(text: "Upcoming"), Tab(text: "Rescheduled")],
      ),
    );
  }

  Widget _buildPatientsList(List<AppointmentEntity> appointments, String emptyMsg) {
    if (appointments.isEmpty) {
      return Center(child: Text(emptyMsg, style: AppTextStyles.bodyMedium));
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.r),
      physics: const BouncingScrollPhysics(),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildPatientCard(appointments[index]);
      },
    );
  }

  Widget _buildPatientCard(AppointmentEntity appointment) {
    final bool hasRealPhoto = appointment.patientImage != null && 
                             appointment.patientImage!.startsWith('http');

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(appointment, hasRealPhoto),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(appointment.patientName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        if (appointment.isReceptionistBooking)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlueSoft,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              "Reception",
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(appointment.caseDescription, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(DateFormat('dd MMM yyyy').format(appointment.date), style: AppTextStyles.bodySmall),
              SizedBox(width: 20.w),
              Icon(Icons.access_time, size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(appointment.time, style: AppTextStyles.bodySmall),
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
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text("Details", style: AppTextStyles.buttonSmall),
                ),
              ),
              if (appointment.status != 'Completed') ...[
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    _viewModel.markAsComplete(appointment.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Appointment with ${appointment.patientName} marked as complete!")),
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

  Widget _buildAvatar(AppointmentEntity appointment, bool hasRealPhoto) {
    if (hasRealPhoto) {
      return CircleAvatar(
        radius: 25.r,
        backgroundImage: NetworkImage(appointment.patientImage!),
      );
    } else {
      final String initials = appointment.patientName.isNotEmpty 
          ? appointment.patientName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
          : "?";
          
      return CircleAvatar(
        radius: 25.r,
        backgroundColor: AppColors.primaryBlueSoft,
        child: Text(
          initials,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 22.r),
    );
  }
}
