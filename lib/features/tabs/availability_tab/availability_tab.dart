import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import 'cubit/availability_view_model.dart';

class AvailabilityTab extends StatefulWidget {
  const AvailabilityTab({super.key});

  @override
  State<AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<AvailabilityTab> {
  late AvailabilityViewModel _viewModel;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<String> _allTimeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
    "11:00 AM", "11:30 AM", "01:00 PM", "01:30 PM",
    "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM",
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<AvailabilityViewModel>();
    _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
    _fetchAvailability();
  }

  void _fetchAvailability() {
    if (_selectedDay != null) {
      _viewModel.getAvailability(_selectedDay!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;
    final String roleLabel = (user?.role?.toLowerCase() == 'doctor') ? (user?.speciality ?? "General Dentist") : "Receptionist";

    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: BlocListener<AvailabilityViewModel, AvailabilityState>(
          listener: (context, state) {
            if (state is AvailabilityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfessionalHeader(user?.fullName ?? "Staff Name", roleLabel),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text("Select a Date & Time", style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                  SizedBox(height: 16.h),
                  _buildAdvancedCalendarSection(),
                  if (_selectedDay != null) ...[
                    SizedBox(height: 32.h),
                    _buildTimeSlotsSection(),
                  ],
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomAvailabilityBar(),
      ),
    );
  }

  Widget _buildProfessionalHeader(String name, String role) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32.r), bottomRight: Radius.circular(32.r)),
        boxShadow: [BoxShadow(color: AppColors.blackColor.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text(role, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 18.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text("30 min duration", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCalendarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: AppColors.blackColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
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
        Text(DateFormat('MMMM yyyy').format(_focusedDay), style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildNavButton(Icons.chevron_left, () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1))),
            SizedBox(width: 12.w),
            _buildNavButton(Icons.chevron_right, () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1))),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(color: AppColors.primaryBlueSoft, borderRadius: BorderRadius.circular(8.r)),
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
          children: dayNames.map((name) => Text(name, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary))).toList(),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 10, crossAxisSpacing: 10),
          itemCount: daysInMonth + (firstDayOfMonth - 1),
          itemBuilder: (context, index) {
            if (index < firstDayOfMonth - 1) return const SizedBox.shrink();
            final day = index - (firstDayOfMonth - 2);
            final date = DateTime(_focusedDay.year, _focusedDay.month, day);
            final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date);
            final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

            return GestureDetector(
              onTap: isPast ? null : () {
                setState(() => _selectedDay = date);
                _viewModel.getAvailability(date);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: isSelected ? AppColors.primaryBlue : Colors.transparent, shape: BoxShape.circle),
                child: Text("$day", style: AppTextStyles.labelMedium.copyWith(color: isSelected ? Colors.white : (isPast ? AppColors.textTertiary : AppColors.textPrimary))),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Available Time Slots", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(DateFormat('EEEE, MMM dd').format(_selectedDay!), style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue)),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: BlocBuilder<AvailabilityViewModel, AvailabilityState>(
            builder: (context, state) {
              if (state is AvailabilityLoading) return const Center(child: CircularProgressIndicator());
              
              List<String> published = [];
              List<String> selected = [];
              List<String> booked = [];

              if (state is AvailabilitySuccess) {
                published = state.publishedSlots;
                selected = state.selectedSlots;
                booked = state.bookedSlots;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12.h, crossAxisSpacing: 12.w, childAspectRatio: 2.2),
                itemCount: _allTimeSlots.length,
                itemBuilder: (context, index) {
                  final time = _allTimeSlots[index];
                  final bool isBooked = booked.contains(time);
                  final bool isLive = published.contains(time);
                  final bool isNew = selected.contains(time);

                  Color bgColor = AppColors.backgroundPrimary;
                  Color borderColor = AppColors.borderSoft;
                  String label = "";

                  if (isBooked) {
                    bgColor = AppColors.errorLight;
                    borderColor = AppColors.error;
                    label = "Booked";
                  } else if (isLive) {
                    bgColor = AppColors.errorLight;
                    borderColor = AppColors.error;
                    label = "Already Available";
                  } else if (isNew) {
                    bgColor = AppColors.primaryBlueSoft;
                    borderColor = AppColors.primaryBlue;
                  }


                  return GestureDetector(
                    onTap: isBooked ? null : () => _viewModel.toggleSlot(time),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: borderColor, width: 1.5)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(time, style: AppTextStyles.labelSmall.copyWith(color: (isBooked || isLive) ? AppColors.error : AppColors.textPrimary, fontWeight: (isLive || isNew || isBooked) ? FontWeight.bold : FontWeight.normal)),
                          if (label.isNotEmpty) Text(label, style: TextStyle(fontSize: 7.sp, color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAvailabilityBar() {
    return BlocBuilder<AvailabilityViewModel, AvailabilityState>(
      builder: (context, state) {
        final bool isSaving = state is AvailabilitySaving;
        int count = 0;
        if (state is AvailabilitySuccess) count = state.publishedSlots.length + state.selectedSlots.length;

        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(color: AppColors.whiteColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("$count Slots Active", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text("For ${DateFormat('MMM dd').format(_selectedDay ?? DateTime.now())}", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ]),
                ElevatedButton(
                  onPressed: isSaving ? null : () => _viewModel.saveAvailability(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                  child: Text(isSaving ? "Saving..." : "Update Schedule", style: AppTextStyles.buttonMedium.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
