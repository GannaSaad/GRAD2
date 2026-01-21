import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class AdminPatientsTab extends StatefulWidget {
  const AdminPatientsTab({super.key});

  @override
  State<AdminPatientsTab> createState() => _AdminPatientsTabState();
}

class _AdminPatientsTabState extends State<AdminPatientsTab> {
  // Mock global patient data for Admin
  final List<Map<String, String>> allPatients = [
    {"name": "Ahmed Mansour", "id": "PT-0012", "doctor": "Dr. Hazem EL Beltagy", "status": "Active"},
    {"name": "Layla Farid", "id": "PT-0045", "doctor": "Dr. Hazem EL Beltagy", "status": "Active"},
    {"name": "Yassin Kareem", "id": "PT-0088", "doctor": "Dr. Mohamed Hmady", "status": "Active"},
    {"name": "Mariam Roushdy", "id": "PT-0102", "doctor": "Dr. Samia Abu Zeed", "status": "Suspended"},
    {"name": "Hassan Zaki", "id": "PT-0156", "doctor": "Dr. Olivia Turner", "status": "Active"},
    {"name": "Zainab Ali", "id": "PT-0189", "doctor": "Dr. Ahmed El-Sherif", "status": "Active"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Platform Patients", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              physics: const BouncingScrollPhysics(),
              itemCount: allPatients.length,
              itemBuilder: (context, index) {
                return _buildPatientRow(context, allPatients[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("Patient Info", style: _headerStyle())),
          Expanded(flex: 2, child: Text("Assigned Doctor", style: _headerStyle())),
          Expanded(flex: 1, child: Text("Manage", style: _headerStyle(), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildPatientRow(BuildContext context, Map<String, String> p, int index) {
    bool isSuspended = p['status'] == 'Suspended';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Name & ID
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p["name"]!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text("ID: ${p["id"]}", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10.sp)),
              ],
            ),
          ),
          // Doctor
          Expanded(
            flex: 2,
            child: Text(
              p["doctor"]!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontSize: 11.sp),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionIcon(
                  Icons.edit_outlined, 
                  AppColors.primaryGold, 
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Editing ${p['name']} profile")),
                    );
                  }
                ),
                SizedBox(width: 8.w),
                _buildActionIcon(
                  isSuspended ? Icons.play_circle_outline : Icons.block_flipped, 
                  isSuspended ? AppColors.success : AppColors.error, 
                  () => _showBlockDialog(context, p, index)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 18.r),
      ),
    );
  }

  TextStyle _headerStyle() => AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue);

  void _showBlockDialog(BuildContext context, Map<String, String> p, int index) {
    bool isSuspended = p['status'] == 'Suspended';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(isSuspended ? "Unblock Account" : "Suspend Account"),
        content: Text("Are you sure you want to ${isSuspended ? 'unblock' : 'suspend'} the account for ${p['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              setState(() {
                allPatients[index]['status'] = isSuspended ? 'Active' : 'Suspended';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${p['name']} has been ${isSuspended ? 'unblocked' : 'suspended'}.")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuspended ? AppColors.success : AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(isSuspended ? "Confirm Unblock" : "Confirm Suspension"),
          ),
        ],
      ),
    );
  }
}
