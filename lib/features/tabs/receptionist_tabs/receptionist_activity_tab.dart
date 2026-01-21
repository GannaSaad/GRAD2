import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class ReceptionistActivityTab extends StatelessWidget {
  const ReceptionistActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock clinical & financial activity data
    final List<Map<String, String>> activities = [
      {"name": "Ahmed Mansour", "id": "DX-0012", "date": "24 Dec 2024", "case": "Extraction", "billing": "1,200 EGP"},
      {"name": "Layla Farid", "id": "DX-0045", "date": "24 Dec 2024", "case": "Checkup", "billing": "500 EGP"},
      {"name": "Yassin Kareem", "id": "DX-0088", "date": "23 Dec 2024", "case": "Root Canal", "billing": "2,500 EGP"},
      {"name": "Mariam Roushdy", "id": "DX-0102", "date": "23 Dec 2024", "case": "Whitening", "billing": "3,000 EGP"},
      {"name": "Hassan Zaki", "id": "DX-0156", "date": "22 Dec 2024", "case": "Cleaning", "billing": "800 EGP"},
      {"name": "Zainab Ali", "id": "DX-0189", "date": "22 Dec 2024", "case": "Consultation", "billing": "500 EGP"},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Clinical Activity", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSummary(),
            SizedBox(height: 24.h),
            Text("Detailed Patient Records", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildActivityTable(activities),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSummaryItem("Today's Revenue", "1,700 EGP"),
          _buildSummaryItem("Pending", "450 EGP"),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
        Text(value, style: AppTextStyles.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActivityTable(List<Map<String, String>> data) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.primaryBlueLight.withOpacity(0.3)),
          horizontalMargin: 12,
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text("Patient", style: _columnStyle())),
            DataColumn(label: Text("ID", style: _columnStyle())),
            DataColumn(label: Text("Date", style: _columnStyle())),
            DataColumn(label: Text("Case", style: _columnStyle())),
            DataColumn(label: Text("Billing", style: _columnStyle())),
          ],
          rows: data.map((item) {
            return DataRow(cells: [
              DataCell(Text(item["name"]!, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
              DataCell(Text(item["id"]!, style: AppTextStyles.bodySmall)),
              DataCell(Text(item["date"]!, style: AppTextStyles.bodySmall)),
              DataCell(Text(item["case"]!, style: AppTextStyles.bodySmall)),
              DataCell(Text(item["billing"]!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  TextStyle _columnStyle() => AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue);
}
