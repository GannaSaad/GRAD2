import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import 'doctors_listing_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  final Doctor doctor;

  const BookAppointmentScreen({super.key, required this.doctor});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  // Mock data for availability
  final List<int> _fullyBookedDays = [15, 20, 25];
  final List<String> _timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
    "11:00 AM", "11:30 AM", "01:00 PM", "01:30 PM",
    "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM"
  ];
  final List<String> _bookedSlots = ["10:30 AM", "02:00 PM"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text("Book Appointment", style: AppTextStyles.titleLarge),
            Text(widget.doctor.name, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Section
            _buildCalendarSection(),
            
            SizedBox(height: 24.h),

            // Time Slots Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text("Available Time Slots", style: AppTextStyles.titleMedium),
            ),
            SizedBox(height: 16.h),
            _buildTimeSlotsGrid(),

            SizedBox(height: 30.h),

            // Summary Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildSummaryCard(),
            ),

            SizedBox(height: 40.h),

            // Payment Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomElevatedButton(
                buttonText: "Continue to Payment",
                onPressed: (_selectedDay != null && _selectedTime != null)
                    ? () {
                        Navigator.pushNamed(context, AppRoutes.paymentMethod);
                      }
                    : null,
                backgroundColor: (_selectedDay != null && _selectedTime != null)
                    ? AppColors.primaryBlue
                    : AppColors.grayColor,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.all(20.r),
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
      child: Column(
        children: [
          _buildCalendarHeader(),
          SizedBox(height: 16.h),
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
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1).weekday;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + (firstDayOfMonth % 7),
      itemBuilder: (context, index) {
        if (index < (firstDayOfMonth % 7)) {
          return const SizedBox.shrink();
        }
        
        final day = index - (firstDayOfMonth % 7) + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final isSelected = _selectedDay != null &&
            _selectedDay!.year == date.year &&
            _selectedDay!.month == date.month &&
            _selectedDay!.day == date.day;
        final isBooked = _fullyBookedDays.contains(day);
        final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

        return GestureDetector(
          onTap: (isBooked || isPast) ? null : () {
            setState(() {
              _selectedDay = date;
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primaryBlue 
                  : (isBooked || isPast ? AppColors.backgroundPrimary : Colors.transparent),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              ),
            ),
            child: Text(
              "$day",
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : (isBooked || isPast ? AppColors.textTertiary : AppColors.textPrimary),
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotsGrid() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 2.5,
        ),
        itemCount: _timeSlots.length,
        itemBuilder: (context, index) {
          final time = _timeSlots[index];
          final isBooked = _bookedSlots.contains(time);
          final isSelected = _selectedTime == time;

          return GestureDetector(
            onTap: isBooked ? null : () {
              setState(() {
                _selectedTime = time;
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryBlue 
                    : (isBooked ? AppColors.backgroundPrimary : AppColors.cardBackground),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft,
                ),
              ),
              child: Text(
                time,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected 
                      ? Colors.white 
                      : (isBooked ? AppColors.textTertiary : AppColors.textPrimary),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlueSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Booking Summary", style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryBlue)),
          const Divider(height: 24),
          _buildSummaryRow(Icons.person_outline, "Doctor", widget.doctor.name),
          _buildSummaryRow(Icons.calendar_today_outlined, "Date", _selectedDay != null ? DateFormat('dd MMMM yyyy').format(_selectedDay!) : "Not selected"),
          _buildSummaryRow(Icons.access_time, "Time", _selectedTime ?? "Not selected"),
          _buildSummaryRow(Icons.payments_outlined, "Consultation", "500 EGP"),
          _buildSummaryRow(Icons.location_on_outlined, "Clinic", widget.doctor.clinic.split('–').first),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 18.r, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Text("$label: ", style: AppTextStyles.labelSmall),
          Expanded(
            child: Text(
              value, 
              style: AppTextStyles.titleSmall.copyWith(fontSize: 13.sp),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
