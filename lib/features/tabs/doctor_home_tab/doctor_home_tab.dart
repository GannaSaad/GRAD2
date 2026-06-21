import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/repos/appointment_repo.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import 'cubit/doctor_home_view_model.dart';

class DoctorHomeTab extends StatefulWidget {
  const DoctorHomeTab({super.key});

  @override
  State<DoctorHomeTab> createState() => _DoctorHomeTabState();
}

class _DoctorHomeTabState extends State<DoctorHomeTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  final DoctorHomeViewModel _viewModel = getIt<DoctorHomeViewModel>();
  
  // Track which patients have completed appointments
  final Map<String, bool> _hasCompletedAppointments = {};

  @override
  void initState() {
    super.initState();
    _viewModel.getAppointments();
  }
  
  // Check if patient has any completed appointments before this date
  Future<bool> _checkPatientHasCompletedAppointments(String patientId, DateTime currentAppointmentDate) async {
    // Check cache first
    if (_hasCompletedAppointments.containsKey(patientId)) {
      return _hasCompletedAppointments[patientId]!;
    }
    
    // Get all appointments for this patient
    try {
      final repo = getIt<AppointmentRepo>();
      final appointments = await repo.getPatientAppointments(patientId).first;
      
      // Check if there's any completed appointment before this date
      final hasCompleted = appointments.any((apt) => 
        apt.status == 'Completed' && apt.date.isBefore(currentAppointmentDate)
      );
      
      // Cache the result
      _hasCompletedAppointments[patientId] = hasCompleted;
      return hasCompleted;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<AuthCubit>().currentUser;

    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildWelcomeHeader(),
                SizedBox(height: 24.h),
                _buildDoctorProfileCard(currentUser),
                SizedBox(height: 24.h),
                _buildCalendarCard(),
                SizedBox(height: 30.h),
                _buildAppointmentsHeader(),
                SizedBox(height: 16.h),
                _buildAppointmentsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          "Welcome to Dentix",
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 3.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorProfileCard(dynamic user) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                Text(
                  user?.fullName ?? "Doctor Name",
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                Text(
                  user?.speciality ?? "Medical Specialist",
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.r, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(
                      user?.clinicName ?? "Dentix Clinic Center",
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 20.h),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM yyyy').format(_focusedDay),
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            _buildHeaderAction(Icons.chevron_left, () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            }),
            SizedBox(width: 8.w),
            _buildHeaderAction(Icons.chevron_right, () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.primaryBlueSoft,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20.r),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;
    final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames.map((name) => Text(name, style: AppTextStyles.labelSmall)).toList(),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: daysInMonth + (firstDayOfMonth - 1),
          itemBuilder: (context, index) {
            if (index < firstDayOfMonth - 1) return const SizedBox.shrink();

            final day = index - (firstDayOfMonth - 2);
            final date = DateTime(_focusedDay.year, _focusedDay.month, day);
            final isSelected = DateUtils.isSameDay(_selectedDate, date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "$day",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Appointments",
          style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat('MMMM dd, yyyy').format(_selectedDate),
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    return BlocBuilder<DoctorHomeViewModel, DoctorHomeState>(
      builder: (context, state) {
        if (state is DoctorHomeLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
        } else if (state is DoctorHomeFailure) {
          return Center(child: Text(state.message));
        } else if (state is DoctorHomeSuccess) {
          final appointments = state.appointments.where((a) => DateUtils.isSameDay(a.date, _selectedDate)).toList();

          if (appointments.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text("No appointments for this day", style: AppTextStyles.bodyMedium),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return FutureBuilder<bool>(
                future: _checkPatientHasCompletedAppointments(appointment.patientId, appointment.date),
                builder: (context, snapshot) {
                  final isFollowUp = snapshot.data ?? false;
                  return _buildAppointmentCard(appointment, isFollowUp);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity appointment, bool isFollowUp) {
    // Detect emergency from boolean flag OR specific status string
    final bool isEmergency = appointment.isEmergency || 
                             appointment.status == 'Emergency Request Pending';
    final bool isCancelled = appointment.status == 'Cancelled';
    final bool hasRealPhoto = appointment.patientImage != null && 
                             appointment.patientImage!.startsWith('http');
    
    // Determine consultation type
    final String consultationType = isFollowUp ? "Follow-up Consultation" : "Initial Consultation";
    final Color consultationColor = isFollowUp ? AppColors.primaryBlue : Colors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: isCancelled 
            ? AppColors.cardBackground.withOpacity(0.5)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: isCancelled 
            ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isCancelled
                ? Colors.red.withOpacity(0.05)
                : isEmergency 
                    ? AppColors.error.withValues(alpha: 0.15) 
                    : AppColors.shadowColor.withValues(alpha: 0.05),
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
              if (isEmergency && !isCancelled)
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
                          Opacity(
                            opacity: isCancelled ? 0.5 : 1.0,
                            child: _buildAvatar(appointment, hasRealPhoto),
                          ),
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
                                          color: isCancelled 
                                              ? AppColors.textSecondary 
                                              : AppColors.textPrimary,
                                          decoration: isCancelled 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCancelled) ...[
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          "CANCELLED",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    if (isEmergency && !isCancelled) ...[
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
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded, 
                                      size: 14.r, 
                                      color: isCancelled 
                                          ? AppColors.textSecondary.withOpacity(0.5)
                                          : AppColors.textSecondary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      appointment.time,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isCancelled
                                            ? AppColors.textSecondary.withOpacity(0.5)
                                            : AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCancelled 
                                            ? TextDecoration.lineThrough 
                                            : null,
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
                      // Only show case description if it's not the default "Initial Consultation"
                      if (appointment.caseDescription.trim().toLowerCase() != "initial consultation") ...[
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
                              color: isCancelled
                                  ? AppColors.textSecondary.withOpacity(0.5)
                                  : AppColors.textSecondary,
                              height: 1.3,
                              decoration: isCancelled 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ],
                      if (!isCancelled) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              isFollowUp ? Icons.replay_rounded : Icons.fiber_new_rounded,
                              size: 16.r,
                              color: consultationColor,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              consultationType,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: consultationColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isEmergency && !isCancelled) ...[
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
                                  onPressed: () => _viewModel.updateAppointmentStatus(appointment.id, 'Confirmed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                  ),
                                  child: Text("Approve Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _viewModel.resolveEmergency(appointment.id, 'Confirmed', false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: BorderSide(color: AppColors.borderSoft),
                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                                  ),
                                  child: Text("Normal Visit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildAvatar(AppointmentEntity appointment, bool hasRealPhoto) {
    if (hasRealPhoto) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlueSoft, width: 2),
        ),
        child: CircleAvatar(
          radius: 28.r,
          backgroundImage: NetworkImage(appointment.patientImage!),
        ),
      );
    } else {
      final String initials = appointment.patientName.isNotEmpty 
          ? appointment.patientName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
          : "?";
          
      return CircleAvatar(
        radius: 28.r,
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
}
