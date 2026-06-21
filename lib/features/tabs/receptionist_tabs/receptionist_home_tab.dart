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
import '../../../domain/repos/appointment_repo.dart';
import '../patients_tab/cubit/patients_view_model.dart';

class ReceptionistHomeTab extends StatefulWidget {
  const ReceptionistHomeTab({super.key});

  @override
  State<ReceptionistHomeTab> createState() => _ReceptionistHomeTabState();
}

class _ReceptionistHomeTabState extends State<ReceptionistHomeTab> {
  late PatientsViewModel _viewModel;
  DateTime _selectedDate = DateTime.now();
  
  // Track which patients have completed appointments
  final Map<String, bool> _hasCompletedAppointments = {};

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
    final user = getIt<AuthCubit>().currentUser;

    return BlocProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user?.fullName ?? "Receptionist"),
              _buildStaffProfileCard(
                doctorName: user?.assignedDoctorName ?? "Doctor",
                clinicName: user?.clinicName ?? "Dentix Clinic Center",
              ),
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

  Widget _buildStaffProfileCard({required String doctorName, required String clinicName}) {
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
              
              return FutureBuilder<bool>(
                future: _checkPatientHasCompletedAppointments(appointment.patientId, appointment.date),
                builder: (context, snapshot) {
                  final isFollowUp = snapshot.data ?? false;
                  return _buildAppointmentCard(appointment, prediction, isFollowUp);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity appointment, NoShowPrediction? prediction, bool isFollowUp) {
    final bool isEmergency = appointment.status == 'Emergency Request Pending';
    final bool isCancelled = appointment.status == 'Cancelled';
    
    // Determine consultation type
    final String consultationType = isFollowUp ? "Follow-up Consultation" : "Initial Consultation";
    final Color consultationColor = isFollowUp ? AppColors.primaryBlue : Colors.green;
    
    Color riskColor = Colors.grey;
    String riskLabel = "";
    if (prediction != null) {
      if (prediction.probability > 70) {
        riskColor = Colors.red;
        riskLabel = "High Risk";
      } else if (prediction.probability > 30) {
        riskColor = Colors.orange;
        riskLabel = "Medium Risk";
      } else {
        riskColor = Colors.green;
        riskLabel = "Low Risk";
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: isEmergency 
            ? Border.all(color: Colors.red, width: 2) 
            : isCancelled 
                ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: isEmergency 
                ? Colors.red.withOpacity(0.1) 
                : isCancelled
                    ? Colors.red.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Material(
        color: isCancelled 
            ? AppColors.cardBackground.withOpacity(0.5) 
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => _showAppointmentDetails(appointment),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? Colors.red.withOpacity(0.1)
                            : isEmergency 
                                ? Colors.red.withOpacity(0.1) 
                                : AppColors.primaryBlueSoft,
                        borderRadius: BorderRadius.circular(14.r)
                      ),
                      child: Text(
                        appointment.time, 
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isCancelled || isEmergency ? Colors.red : AppColors.primaryBlue, 
                          fontWeight: FontWeight.w900,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        )
                      ),
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
                                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                                  )
                                ),
                              ),
                              if (isCancelled) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6.r)
                                  ),
                                  child: Text(
                                    "CANCELLED",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ],
                              if (isEmergency) ...[
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4.r)),
                                  child: Text("URGENT", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          // Show case description ONLY if it's not "Initial Consultation"
                          if (appointment.caseDescription.trim().toLowerCase() != "initial consultation")
                            Text(
                              appointment.caseDescription, 
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                              )
                            ),
                          // Show consultation type badge
                          if (!isCancelled) ...[
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  isFollowUp ? Icons.replay_rounded : Icons.fiber_new_rounded,
                                  size: 12.r,
                                  color: consultationColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  consultationType,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: consultationColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (prediction != null && !isCancelled) ...[
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 14.r,
                                  color: riskColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "$riskLabel (${prediction.probability.toStringAsFixed(0)}% no-show)",
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: riskColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(Icons.more_vert, color: AppColors.textPlaceholder),
                  ],
                ),
                if (isEmergency) ...[
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Reason: ${appointment.emergencyReason}",
                          style: AppTextStyles.labelSmall.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _viewModel.updateAppointmentStatus(appointment.id, 'Confirmed'),
                        child: const Text("Approve", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () => _viewModel.updateAppointmentStatus(appointment.id, 'Cancelled'),
                        child: const Text("Reject", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAppointmentDetails(AppointmentEntity appointment) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Appointment Details", style: AppTextStyles.titleLarge),
            SizedBox(height: 20.h),
            _detailRow("Patient", appointment.patientName),
            _detailRow("Time", appointment.time),
            _detailRow("Status", appointment.status),
            if (appointment.isEmergency) ...[
              const Divider(),
              Text("Emergency Info", style: AppTextStyles.titleMedium.copyWith(color: Colors.red)),
              _detailRow("Reason", appointment.emergencyReason ?? "N/A"),
              _detailRow("Description", appointment.emergencyDescription ?? "N/A"),
            ],
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
