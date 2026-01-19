import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_routes.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../patients_tab/patients_tab.dart';

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  String searchQuery = '';
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> _doctors = [
    {
      "name": "Dr. Hazem EL Beltagy",
      "field": "Implantology",
      "location": "Cairo",
      "patients": 124,
      "image": "assets/images/doctor.jpg"
    },
    {
      "name": "Dr. Mohamed Hmady",
      "field": "Dermatology",
      "location": "Maadi",
      "patients": 89,
      "image": "assets/images/doctor1.png"
    },
    {
      "name": "Dr. Samia Abu Zeed",
      "field": "Endocrinology",
      "location": "Zamalek",
      "patients": 156,
      "image": "assets/images/doctor3.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Admin Dashboard", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primaryBlue),
            onPressed: () {
              // Add Doctor Logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                return _buildAdminDoctorCard(_doctors[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          TextField(
            onChanged: (val) => setState(() => searchQuery = val),
            decoration: InputDecoration(
              hintText: "Search by name or specialty...",
              prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ["All", "Implantology", "Dermatology", "Endocrinology"].map((filter) {
                bool isSelected = selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => selectedFilter = filter),
                  child: Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : AppColors.primaryBlueLight,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      filter,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: AssetImage(doctor["image"]),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor["name"], style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text("${doctor["field"]} • ${doctor["location"]}", style: AppTextStyles.bodySmall),
                    SizedBox(height: 4.h),
                    Text("${doctor["patients"]} Total Patients", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.adminDoctorDetail, arguments: doctor);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    side: const BorderSide(color: AppColors.primaryBlue),
                  ),
                  child: Text("View Details", style: AppTextStyles.buttonSmall.copyWith(color: AppColors.primaryBlue)),
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                onPressed: () {
                  // Delete Logic
                },
                icon: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
