import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repos/appointment_repo.dart';
import 'cubit/booking_view_model.dart';
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
  final BookingViewModel _viewModel = getIt<BookingViewModel>();

  @override
  void initState() {
    super.initState();
    //
    // Normalize today's date
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _viewModel.fetchBookedSlots(widget.doctor.id, _selectedDay!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Book Appointment", style: AppTextStyles.titleLarge),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfessionalHeader(),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text("Select a Date & Time", style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 16.h),
              _buildAdvancedCalendarSection(),
              
              if (_selectedDay != null) ...[
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text("Available Time Slots", style: AppTextStyles.titleMedium),
                ),
                SizedBox(height: 16.h),
                _buildDynamicTimeSlotsGrid(),
              ],

              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: _buildSummaryCard(),
              ),
              SizedBox(height: 40.h),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: CustomElevatedButton(
                  buttonText: "Continue to Payment",
                  onPressed: (_selectedDay != null && _selectedTime != null)
                      ? () => Navigator.pushNamed(
                            context, 
                            AppRoutes.paymentMethod, 
                            arguments: {
                              'doctor': widget.doctor,
                              'date': _selectedDay,
                              'time': _selectedTime,
                            }
                          )
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
      ),
    );
  }

  Widget _buildDynamicTimeSlotsGrid() {
    return StreamBuilder<AvailabilityEntity?>(
      stream: getIt<AppointmentRepo>().getDoctorAvailability(widget.doctor.id, _selectedDay!),
      builder: (context, availabilitySnapshot) {
        return BlocBuilder<BookingViewModel, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading || availabilitySnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            final List<String> liveSlots = availabilitySnapshot.data?.availableSlots ?? [];
            
            List<String> bookedSlots = [];
            if (state is BookedSlotsLoaded) {
              bookedSlots = state.bookedSlots;
            }

            // PATIENT ONLY SEES: Live slots that aren't booked
            final filteredSlots = liveSlots.where((slot) => !bookedSlots.contains(slot)).toList();

            if (filteredSlots.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Text("No available slots for this date.", style: AppTextStyles.bodyMedium),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 2.2,
                ),
                itemCount: filteredSlots.length,
                itemBuilder: (context, index) {
                  final time = filteredSlots[index];
                  final isSelected = _selectedTime == time;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime = time;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft, width: 1.5),
                      ),
                      child: Text(
                        time,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfessionalHeader() {
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
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: AssetImage(widget.doctor.image),
              ),
              SizedBox(width: 16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.doctor.name, style: AppTextStyles.titleLarge),
                  Text(widget.doctor.specialty, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(Icons.access_time, size: 18.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text("30 min duration", style: AppTextStyles.bodySmall),
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
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.public, size: 14.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text("Egypt Standard Time (GMT+2)", style: AppTextStyles.labelSmall),
            ],
          ),
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
          children: dayNames.map((name) => Text(name, style: AppTextStyles.labelSmall)).toList(),
        ),
        SizedBox(height: 16.h),
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
            final isSelected = _selectedDay != null && DateUtils.isSameDay(_selectedDay!, date);
            final isToday = DateUtils.isSameDay(DateTime.now(), date);
            final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

            return GestureDetector(
              onTap: isPast ? null : () {
                setState(() {
                  _selectedDay = date;
                  _selectedTime = null;
                });
                _viewModel.fetchBookedSlots(widget.doctor.id, date);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday && !isSelected ? Border.all(color: AppColors.primaryBlue, width: 1) : null,
                ),
                child: Text(
                  "$day",
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : (isPast ? AppColors.textTertiary : AppColors.textPrimary),
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                    decoration: isPast ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primaryBlueSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow(Icons.calendar_today_outlined, "Date", _selectedDay != null ? DateFormat('EEEE, dd MMM yyyy').format(_selectedDay!) : "Select a date"),
          _buildSummaryRow(Icons.access_time, "Time", _selectedTime ?? "Select a slot"),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Consultation Fee", style: AppTextStyles.bodyMedium),
              Text("500 EGP", style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Text("$label: ", style: AppTextStyles.labelSmall),
          Text(value, style: AppTextStyles.titleSmall.copyWith(fontSize: 13.sp)),
        ],
      ),
    );
  }
}
