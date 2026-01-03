import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';

class PatientData {
  final String name;
  final String image;
  String status;

  PatientData({required this.name, required this.image, required this.status});
}

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  State<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<PatientData> _allPatients = [
    PatientData(name: "Ahmed Mansour", image: "assets/images/patient.jpeg", status: "Upcoming"),
    PatientData(name: "Layla Farid", image: "assets/images/patient1.jpeg", status: "Complete"),
    PatientData(name: "Yassin Kareem", image: "assets/images/patient2.jpeg", status: "Upcoming"),
    PatientData(name: "Mariam Roushdy", image: "assets/images/patient3.jpeg", status: "Rescheduled"),
    PatientData(name: "Hassan Zaki", image: "assets/images/patient4.jpeg", status: "Complete"),
    PatientData(name: "Zainab Ali", image: "assets/images/patient5.jpeg", status: "Upcoming"),
    PatientData(name: "Omar Sharif", image: "assets/images/patient6.jpeg", status: "Rescheduled"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () {},
        ),
        title: Text("Patients", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPatientsList('Complete'),
                _buildPatientsList('Upcoming'),
                _buildPatientsList('Rescheduled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
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
        labelStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 13.sp),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: "Complete"),
          Tab(text: "Upcoming"),
          Tab(text: "Rescheduled"),
        ],
      ),
    );
  }

  Widget _buildPatientsList(String status) {
    final filteredList = _allPatients.where((p) => p.status == status).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text("No patients in this category", style: AppTextStyles.bodyMedium),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.r),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        return _buildPatientCard(filteredList[index]);
      },
    );
  }

  Widget _buildPatientCard(PatientData patient) {
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
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: AssetImage(patient.image),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text("4 visits • Routine scaling & polishing", style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text("12 Dec 2024", style: AppTextStyles.bodySmall),
              SizedBox(width: 20.w),
              Icon(Icons.access_time, size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text("09:00 AM", style: AppTextStyles.bodySmall),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.patientDetails,
                      arguments: {'name': patient.name, 'image': patient.image}
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text("Details", style: AppTextStyles.buttonSmall),
                ),
              ),
              if (patient.status != 'Complete') ...[
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      patient.status = 'Complete';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Appointment with ${patient.name} marked as complete!")),
                    );
                  },
                  child: _buildActionIcon(Icons.check_circle_outline, Colors.green),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    _showCancelDialog(patient);
                  },
                  child: _buildActionIcon(Icons.cancel_outlined, Colors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(PatientData patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: Text("Are you sure you want to cancel the appointment with ${patient.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
            onPressed: () {
              setState(() {
                _allPatients.remove(patient);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Appointment with ${patient.name} cancelled.")),
              );
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 22.r),
    );
  }
}
