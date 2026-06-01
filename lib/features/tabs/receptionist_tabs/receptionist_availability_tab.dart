import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class ReceptionistAvailabilityTab extends StatefulWidget {
  const ReceptionistAvailabilityTab({super.key});

  @override
  State<ReceptionistAvailabilityTab> createState() => _ReceptionistAvailabilityTabState();
}

class _ReceptionistAvailabilityTabState extends State<ReceptionistAvailabilityTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  // Mock data for availability and appointments
  final Map<String, List<Map<String, dynamic>>> _scheduleData = {
    // Key is yyyy-MM-dd
    DateFormat('yyyy-MM-dd').format(DateTime.now()): [
      {"time": "09:00 AM", "type": "Available", "patient": null},
      {"time": "09:30 AM", "type": "Booked", "patient": "Ahmed Mansour", "case": "Consultation"},
      {"time": "10:00 AM", "type": "Available", "patient": null},
      {"time": "10:30 AM", "type": "Booked", "patient": "Layla Farid", "case": "Checkup"},
      {"time": "11:00 AM", "type": "Available", "patient": null},
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Manage Availability", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
        actions: [
          IconButton(
            // REMOVED 'const' because AppColors.primaryBlue is not a constant
            // CHANGED icon to calendar_month (add_calendar_sharp is not valid)
            icon: Icon(Icons.calendar_month, color: AppColors.primaryBlue),
            onPressed: _showAddAvailabilityDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarSection(),
          SizedBox(height: 24.h),
          Expanded(child: _buildSlotsSection()),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
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
      borderRadius: BorderRadius.circular(8.r),
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
              onTap: () => setState(() => _selectedDate = date),
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

  Widget _buildSlotsSection() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final slots = _scheduleData[dateKey] ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(32.r), topRight: Radius.circular(32.r)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Schedule for ${DateFormat('MMM dd').format(_selectedDate)}", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              if (slots.isEmpty)
                TextButton.icon(
                  onPressed: _showAddAvailabilityDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Slots"),
                )
            ],
          ),
          SizedBox(height: 16.h),
          if (slots.isEmpty)
            Center(child: Padding(
              padding: EdgeInsets.only(top: 40.h),
              child: Text("No availability set for this date", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
            ))
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: slots.length,
                itemBuilder: (context, index) => _buildSlotCard(slots[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    bool isBooked = slot['type'] == 'Booked';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isBooked ? AppColors.primaryBlueSoft : AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Text(slot['time'], style: AppTextStyles.titleSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isBooked ? slot['patient'] : "Available Slot", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                if (isBooked) Text(slot['case'], style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Row(
            children: [
              if (isBooked) ...[
                _buildActionButton(Icons.edit_outlined, Colors.blue, () {}),
                SizedBox(width: 8.w),
                _buildActionButton(Icons.cancel_outlined, Colors.red, () {}),
              ] else
                _buildActionButton(Icons.delete_outline, AppColors.textTertiary, () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, color: color, size: 18.r),
      ),
    );
  }

  void _showAddAvailabilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text("Set Doctor Availability"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Upload schedule or set manual hours for the selected date."),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload from Website"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45.h)),
            ),
          ],
        ),
      ),
    );
  }
}
