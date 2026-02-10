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
import '../patients_tab/cubit/patients_view_model.dart';
import 'cubit/request_view_model.dart';

class NurseHomeTab extends StatefulWidget {
  const NurseHomeTab({super.key});

  @override
  State<NurseHomeTab> createState() => _NurseHomeTabState();
}

class _NurseHomeTabState extends State<NurseHomeTab> {
  late PatientsViewModel _patientsViewModel;
  late RequestViewModel _requestViewModel;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _patientsViewModel = getIt<PatientsViewModel>();
    _requestViewModel = getIt<RequestViewModel>();
    _fetchData();
  }

  void _fetchData() {
    final user = getIt<AuthCubit>().currentUser;
    if (user != null && user.assignedDoctorId != null) {
      _patientsViewModel.getAppointmentsForDoctor(user.assignedDoctorId!);
      _requestViewModel.fetchRequests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => _patientsViewModel),
        BlocProvider(create: (context) => _requestViewModel),
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: BlocBuilder<PatientsViewModel, PatientsState>(
            builder: (context, patientState) {
              return BlocBuilder<RequestViewModel, RequestState>(
                builder: (context, requestState) {
                  int patientCount = 0;
                  if (patientState is PatientsSuccess) {
                    patientCount = patientState.appointments.where((a) => DateUtils.isSameDay(a.date, _selectedDate)).length;
                  }

                  int pendingRequests = 0;
                  if (requestState is RequestSuccess) {
                    pendingRequests = requestState.requests.where((r) => r.status == 'Pending').length;
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(user?.fullName ?? "Assistant"),
                        SizedBox(height: 24.h),
                        _buildNurseProfileCard(user?.assignedDoctorName ?? "Doctor"),
                        SizedBox(height: 30.h),
                        
                        _buildDailyTaskSummary(patientCount, pendingRequests),
                        
                        SizedBox(height: 30.h),
                        _buildSectionTitle("Weekly Schedule"),
                        SizedBox(height: 16.h),
                        _buildWeekCalendar(),
                        SizedBox(height: 24.h),
                        _buildScheduleList(patientState),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome back,", style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
        Text(name, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildNurseProfileCard(String doctorName) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, size: 40.r, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Assigned to: $doctorName", style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
                Text("Clinical Assistant", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.r, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text("Clinic A - Floor 2", style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTaskSummary(int patientCount, int pendingRequests) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTaskCard(patientCount.toString(), "Patients", Icons.people_outline, AppColors.primaryBlue),
        _buildTaskCard(pendingRequests.toString(), "Requests", Icons.pending_actions, Colors.orange), 
        _buildTaskCard("Low", "Inventory", Icons.inventory_2_outlined, Colors.red),
      ],
    );
  }

  Widget _buildTaskCard(String value, String label, IconData icon, Color color) {
    return Container(
      width: 105.w,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 8.h),
          Text(value, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildWeekCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = today.add(Duration(days: index));
        final isSelected = DateUtils.isSameDay(_selectedDate, date);
        
        return GestureDetector(
          onTap: () => setState(() => _selectedDate = date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45.w,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft),
            ),
            child: Column(
              children: [
                Text(DateFormat('E').format(date)[0], style: AppTextStyles.labelSmall.copyWith(color: isSelected ? Colors.white70 : AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text(date.day.toString(), style: AppTextStyles.titleSmall.copyWith(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScheduleList(PatientsState state) {
    if (state is PatientsLoading) return const Center(child: CircularProgressIndicator());
    if (state is PatientsFailure) return Center(child: Text(state.message));
    if (state is PatientsSuccess) {
      final dailyAppointments = state.appointments.where((a) => DateUtils.isSameDay(a.date, _selectedDate)).toList();
      
      if (dailyAppointments.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              children: [
                Icon(Icons.event_busy, color: AppColors.textPlaceholder, size: 48.r),
                SizedBox(height: 12.h),
                Text("No appointments for this day", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }

      return Column(
        children: dailyAppointments.map((a) => _buildScheduleItem(a)).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildScheduleItem(AppointmentEntity appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () {
            Navigator.pushNamed(
              context, 
              AppRoutes.nursePatientDetails, 
              arguments: {
                'name': appointment.patientName, 
                'image': appointment.patientImage ?? 'assets/images/patient.jpeg',
                'id': appointment.id,
                'time': appointment.time,
                'task': appointment.caseDescription
              }
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                CircleAvatar(radius: 30.r, backgroundColor: AppColors.primaryBlueSoft, child: Text(appointment.patientName[0], style: const TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(appointment.caseDescription, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(appointment.time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: AppColors.primaryBlueLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8.r)),
                      child: Text("Room 1", style: AppTextStyles.labelSmall.copyWith(fontSize: 9.sp, color: AppColors.primaryBlue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
