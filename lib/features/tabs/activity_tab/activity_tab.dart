import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/appointment_entity.dart';
import 'cubit/activity_view_model.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ActivityViewModel _viewModel = getIt<ActivityViewModel>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _viewModel.getAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showReschedulePicker(AppointmentEntity appointment) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null && mounted) {
      _viewModel.fetchAvailableSlots(appointment.doctorId, pickedDate);
      _showTimeSlotDialog(appointment, pickedDate);
    }
  }

  void _showTimeSlotDialog(AppointmentEntity appointment, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _viewModel,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text("Select Time Slot", style: AppTextStyles.titleMedium),
          content: BlocBuilder<ActivityViewModel, ActivityState>(
            builder: (context, state) {
              if (state is ActivityLoading) {
                return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
              }
              if (state is ActivityBookedSlotsLoaded) {
                return SizedBox(
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2,
                    ),
                    itemCount: state.availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = state.availableSlots[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _viewModel.rescheduleAppointment(appointment.id, date, slot);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlueSoft,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.primaryBlue),
                          ),
                          child: Text(slot, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                );
              }
              return const Text("Loading slots...");
            },
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(AppointmentEntity appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text("Cancel Appointment"),
        content: Text("Are you sure you want to cancel your visit with ${appointment.doctorName}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep it")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _viewModel.cancelAppointment(appointment.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text("Yes, Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: BlocListener<ActivityViewModel, ActivityState>(
          listener: (context, state) {
            if (state is ActivitySuccess && state.actionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.actionMessage!), backgroundColor: AppColors.success),
              );
            } else if (state is ActivityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 20.h),
                _buildTabBar(),
                Expanded(
                  child: BlocBuilder<ActivityViewModel, ActivityState>(
                    builder: (context, state) {
                      if (state is ActivityLoading) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                      }
                      
                      final List<AppointmentEntity> appointments = (state is ActivitySuccess) 
                          ? state.appointments 
                          : [];

                      final upcoming = appointments.where((a) => a.status != 'Completed' && a.status != 'Cancelled').toList();
                      final previous = appointments.where((a) => a.status == 'Completed' || a.status == 'Cancelled').toList();

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAppointmentList(upcoming, false),
                          _buildAppointmentList(previous, true),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.r), bottomRight: Radius.circular(30.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Activity", style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
          SizedBox(height: 4.h),
          Text("Your appointment history", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(12.r)),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        tabs: const [Tab(text: "Upcoming"), Tab(text: "Previous")],
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentEntity> list, bool isPrevious) {
    if (list.isEmpty) {
      return Center(child: Text(isPrevious ? "No past appointments" : "No upcoming appointments", style: AppTextStyles.bodyMedium));
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.r),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildAppointmentCard(list[index], isPrevious),
    );
  }

  Widget _buildAppointmentCard(AppointmentEntity appointment, bool isPrevious) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.doctorName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text("Specialist", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryColor)),
                ],
              ),
              _buildStatusBadge(appointment.status),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Icons.location_on_outlined, appointment.clinicName),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildInfoRow(Icons.calendar_today_outlined, DateFormat('dd MMM yyyy').format(appointment.date)),
              SizedBox(width: 24.w),
              _buildInfoRow(Icons.access_time, appointment.time),
            ],
          ),
          if (!isPrevious) ...[
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showCancelConfirmation(appointment),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      side: const BorderSide(color: AppColors.borderMedium),
                    ),
                    child: Text("Cancel", style: AppTextStyles.buttonSmall.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showReschedulePicker(appointment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text("Reschedule", style: AppTextStyles.buttonSmall),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.primaryBlue;
    if (status == 'Completed') color = AppColors.success;
    if (status == 'Cancelled') color = AppColors.error;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
      child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Text(text, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
