import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/appointment_entity.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel.getAppointments();
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
                      "Dentix Clinic Center",
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
              return _buildAppointmentCard(appointments[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity appointment) {
    // Detect emergency from boolean flag OR specific status string
    final bool isEmergency = appointment.isEmergency || 
                             appointment.status == 'Emergency Request Pending';
    final bool hasRealPhoto = appointment.patientImage != null && 
                             appointment.patientImage!.startsWith('http');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: isEmergency 
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
              if (isEmergency)
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
                          _buildAvatar(appointment, hasRealPhoto),
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
                                    if (isEmergency) ...[
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
                      if (isEmergency) ...[
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
                        
                        // Action buttons only if not already confirmed
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
                                  child: Text("Approve", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _viewModel.resolveEmergency(appointment.id, 'Confirmed', false),
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
                                  onPressed: () => _viewModel.updateAppointmentStatus(appointment.id, 'Cancelled'),
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
