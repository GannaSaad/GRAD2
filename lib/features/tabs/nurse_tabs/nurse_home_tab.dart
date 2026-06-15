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

                  return RefreshIndicator(
                    onRefresh: () async => _fetchData(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeHeader(user?.fullName ?? "Assistant"),
                          SizedBox(height: 24.h),
                          _buildNurseProfileCard(
                            doctorName: user?.assignedDoctorName ?? "Doctor",
                            clinicName: user?.clinicName ?? "Dentix Clinic Center",
                          ),
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

  Widget _buildNurseProfileCard({required String doctorName, required String clinicName}) {
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
                    Text(clinicName, style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
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
    final bool isEmergency = appointment.isEmergency || appointment.status == 'Emergency Request Pending';
    
    if (isEmergency) {
      return _buildEmergencyCard(appointment);
    }

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
                _buildAvatar(appointment),
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

  Widget _buildEmergencyCard(AppointmentEntity appointment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.error, Color(0xFFFF8A65)],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildAvatar(appointment),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        appointment.patientName, 
                                        style: AppTextStyles.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorLight,
                                        borderRadius: BorderRadius.circular(100.r),
                                      ),
                                      child: Text(
                                        "URGENT", 
                                        style: TextStyle(
                                          color: AppColors.error, 
                                          fontSize: 9.sp, 
                                          fontWeight: FontWeight.w900,
                                        )
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 14.r, color: AppColors.textSecondary),
                                    SizedBox(width: 4.w),
                                    Text(
                                      appointment.time,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundPrimary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          appointment.caseDescription,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notification_important_rounded, color: AppColors.error, size: 20.r),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Emergency Reason",
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    appointment.emergencyReason ?? "N/A",
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (appointment.status == 'Emergency Request Pending') ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _patientsViewModel.updateAppointmentStatus(appointment.id, 'Confirmed'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                ),
                                child: Text("Approve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _patientsViewModel.resolveEmergency(appointment.id, 'Confirmed', false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryGold,
                                  side: const BorderSide(color: AppColors.primaryGold),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                ),
                                child: Text("Mark Normal", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _patientsViewModel.updateAppointmentStatus(appointment.id, 'Cancelled'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                ),
                                child: Text("Decline", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppointmentEntity appointment) {
    if (appointment.patientImage != null && appointment.patientImage!.startsWith('http')) {
      return CircleAvatar(
        radius: 28.r,
        backgroundImage: NetworkImage(appointment.patientImage!),
      );
    } else {
      return CircleAvatar(
        radius: 28.r,
        backgroundColor: AppColors.primaryBlueSoft,
        child: Text(
          appointment.patientName.isNotEmpty ? appointment.patientName[0] : "?",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
        ),
      );
    }
  }
}
