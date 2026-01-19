import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';

class ReceptionistHomeTab extends StatefulWidget {
  const ReceptionistHomeTab({super.key});

  @override
  State<ReceptionistHomeTab> createState() => _ReceptionistHomeTabState();
}

class _ReceptionistHomeTabState extends State<ReceptionistHomeTab> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, String>> _patientPool = [
    {"name": "Ahmed Mansour", "case": "Root Canal - Phase 2", "image": "assets/images/patient.jpeg"},
    {"name": "Layla Farid", "case": "Routine Checkup", "image": "assets/images/patient1.jpeg"},
    {"name": "Yassin Kareem", "case": "Tooth Extraction", "image": "assets/images/patient2.jpeg"},
    {"name": "Mariam Roushdy", "case": "Teeth Whitening", "image": "assets/images/patient3.jpeg"},
    {"name": "Hassan Zaki", "case": "Braces Adjustment", "image": "assets/images/patient4.jpeg"},
    {"name": "Sara Ahmed", "case": "Consultation", "image": "assets/images/patient5.jpeg"},
    {"name": "Omar Ali", "case": "Scaling & Polishing", "image": "assets/images/patient6.jpeg"},
  ];

  final Map<String, List<Map<String, String>>> _dailySchedules = {};

  @override
  void initState() {
    super.initState();
    _generateScheduleForDate(_selectedDate);
  }

  void _generateScheduleForDate(DateTime date) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
    if (!_dailySchedules.containsKey(dateKey)) {
      final random = Random(date.day + date.month + date.year);
      final int count = 4 + random.nextInt(3); // 4 to 6 patients
      final shuffledPool = List<Map<String, String>>.from(_patientPool)..shuffle(random);
      
      final List<String> times = ["09:00 AM", "10:30 AM", "01:00 PM", "02:30 PM", "04:00 PM", "05:30 PM"];
      final List<Map<String, String>> schedule = [];
      
      for (int i = 0; i < count && i < times.length; i++) {
        final patient = Map<String, String>.from(shuffledPool[i]);
        patient["time"] = times[i];
        schedule.add(patient);
      }
      _dailySchedules[dateKey] = schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final List<Map<String, String>> schedule = _dailySchedules[dateKey] ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCalendarStrip(),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                "Today's Schedule",
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                itemCount: schedule.length,
                itemBuilder: (context, index) {
                  return _buildAppointmentCard(schedule[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back,",
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            "Ganna Saad",
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primaryBlue, // Dark Coffee Brown
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        itemCount: 14,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected = DateUtils.isSameDay(_selectedDate, date);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
                _generateScheduleForDate(date);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 65.w,
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                ] : [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "${date.day}",
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, String> data) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
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
                'name': data["name"]!,
                'image': data["image"]!,
                'case': data["case"]!,
                'time': data["time"]!,
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueSoft, 
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Text(
                    data["time"]!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["name"]!, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text(data["case"]!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
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
