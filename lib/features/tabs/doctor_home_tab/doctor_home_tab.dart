import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class DoctorHomeTab extends StatefulWidget {
  const DoctorHomeTab({super.key});

  @override
  State<DoctorHomeTab> createState() => _DoctorHomeTabState();
}

class _DoctorHomeTabState extends State<DoctorHomeTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _appointments = [
    {"name": "Ahmed Ali", "type": "Checkup", "time": "09:00 AM", "initials": "AA"},
    {"name": "Sara Hassan", "type": "Consultation", "time": "10:30 AM", "initials": "SH"},
    {"name": "Omar Mahmoud", "type": "Root Canal", "time": "01:00 PM", "initials": "OM"},
    {"name": "Laila Youssef", "type": "Cleaning", "time": "03:00 PM", "initials": "LY"},
  ];

  // Mock data for days with appointments
  final List<int> _appointmentDays = [10, 15, 21, 22, 28];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildDoctorProfileCard(),
              SizedBox(height: 24.h),
              
              // Integrated Calendar
              _buildCalendarCard(),
              
              SizedBox(height: 30.h),
              _buildAppointmentsHeader(),
              SizedBox(height: 16.h),
              _buildAppointmentsList(),
            ],
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

  Widget _buildDoctorProfileCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
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
                  "Dr. Hazem EL Beltagy",
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
                Text(
                  "Implantologist Specialist",
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14.r, color: Colors.white70),
                    SizedBox(width: 4.w),
                    Text(
                      "Cairo University Dental Center",
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
            final hasAppointment = _appointmentDays.contains(day);

            return GestureDetector(
              onTap: () {
                setState(() => _selectedDate = date);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "$day",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (hasAppointment && !isSelected)
                      Positioned(
                        bottom: 4.h,
                        child: Container(
                          height: 4.r,
                          width: 4.r,
                          decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                        ),
                      ),
                  ],
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, String> appointment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50.r,
            width: 50.r,
            decoration: BoxDecoration(
              color: AppColors.primaryBlueSoft,
              borderRadius: BorderRadius.circular(12.r),
            ),
            alignment: Alignment.center,
            child: Text(
              appointment["initials"]!,
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment["name"]!, style: AppTextStyles.titleMedium),
                Text(appointment["type"]!, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              appointment["time"]!,
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
