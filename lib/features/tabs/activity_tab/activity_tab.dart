import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUpcomingList(),
                  _buildPreviousList(),
                ],
              ),
            ),
          ],
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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity",
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            "Your appointment history",
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "Upcoming"),
          Tab(text: "Previous"),
        ],
      ),
    );
  }

  Widget _buildUpcomingList() {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        _buildAppointmentCard(
          doctorName: "Dr. Hazem EL Beltagy",
          specialty: "Implantologist",
          status: "Upcoming",
          clinic: "Cairo University Dental Center",
          date: "15 Dec 2024",
          time: "03:30 PM",
          statusColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildPreviousList() {
    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        _buildAppointmentCard(
          doctorName: "Dr. Lina Fathy",
          specialty: "Pediatric Dentistry",
          status: "Completed",
          clinic: "New Cairo Kids Dental Center",
          date: "05 Dec 2024",
          time: "11:00 AM",
          statusColor: Colors.green,
          isPrevious: true,
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String doctorName,
    required String specialty,
    required String status,
    required String clinic,
    required String date,
    required String time,
    required Color statusColor,
    bool isPrevious = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  Text(doctorName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  Text(specialty, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryColor)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow(Icons.location_on_outlined, clinic),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildInfoRow(Icons.calendar_today_outlined, date),
              SizedBox(width: 24.w),
              _buildInfoRow(Icons.access_time, time),
            ],
          ),
          if (!isPrevious) ...[
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
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
                    onPressed: () {},
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
