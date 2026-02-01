import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/entities/no_show_prediction.dart';
import '../patients_tab/cubit/patients_view_model.dart';

class ReceptionistHomeTab extends StatefulWidget {
  const ReceptionistHomeTab({super.key});

  @override
  State<ReceptionistHomeTab> createState() => _ReceptionistHomeTabState();
}

class _ReceptionistHomeTabState extends State<ReceptionistHomeTab> {
  late PatientsViewModel _viewModel;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<PatientsViewModel>();
    _fetchAppointments();
  }

  void _fetchAppointments() {
    final user = getIt<AuthCubit>().currentUser;
    if (user != null && user.assignedDoctorId != null) {
      _viewModel.getAppointmentsForDoctor(user.assignedDoctorId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;

    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.fullName ?? "Receptionist"),
              _buildNurseProfileCard(user?.assignedDoctorName ?? "Doctor"),
              SizedBox(height: 20.h),
              _buildCalendarStrip(),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  "Scheduled Appointments",
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: _buildScheduleList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Welcome back,", style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
          Text(name, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildNurseProfileCard(String doctorName) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: Colors.white24,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assigned to: $doctorName", style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                Text("Front Desk Coordinator", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = today.add(Duration(days: index));
          bool isSelected = DateUtils.isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65.w,
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
                ] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(date), style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white70 : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6.h),
                  Text("${date.day}", style: AppTextStyles.titleLarge.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    return BlocBuilder<PatientsViewModel, PatientsState>(
      builder: (context, state) {
        if (state is PatientsLoading) return const Center(child: CircularProgressIndicator());
        if (state is PatientsFailure) return Center(child: Text(state.message));
        if (state is PatientsSuccess) {
          final dailyAppointments = state.appointments.where((a) => DateUtils.isSameDay(a.date, _selectedDate)).toList();
          
          if (dailyAppointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, color: AppColors.textPlaceholder, size: 48.r),
                  SizedBox(height: 12.h),
                  Text("No appointments for this day", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            physics: const BouncingScrollPhysics(),
            itemCount: dailyAppointments.length,
            itemBuilder: (context, index) {
              final appointment = dailyAppointments[index];
              final prediction = state.predictions[appointment.patientId];
              return _buildAppointmentCard(appointment, prediction);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity appointment, NoShowPrediction? prediction) {
    Color riskColor = Colors.grey;
    if (prediction != null) {
      if (prediction.probability > 70) riskColor = Colors.red;
      else if (prediction.probability > 30) riskColor = Colors.orange;
      else riskColor = Colors.green;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.receptionistPatientDetails,
              arguments: {
                'name': appointment.patientName,
                'image': appointment.patientImage ?? 'assets/images/patient.jpeg',
                'case': appointment.caseDescription,
                'time': appointment.time,
                'patientId': appointment.patientId,
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(14.r)),
                  child: Text(appointment.time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w900)),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(appointment.caseDescription, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                      if (prediction != null) ...[
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              width: 8.r,
                              height: 8.r,
                              decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              "${prediction.probability.toStringAsFixed(1)}% No-Show Risk",
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
                Icon(Icons.arrow_forward_ios_rounded, size: 16.r, color: AppColors.textPlaceholder),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
