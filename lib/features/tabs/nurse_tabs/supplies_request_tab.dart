import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';

class SupplyRequest {
  final String id;
  final String itemName;
  final int quantity;
  final String supplier;
  final String status; // 'Pending', 'Approved', 'Shipped', 'Received'
  final String date;

  SupplyRequest({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.supplier,
    required this.status,
    required this.date,
  });
}

class SuppliesRequestTab extends StatefulWidget {
  const SuppliesRequestTab({super.key});

  @override
  State<SuppliesRequestTab> createState() => _SuppliesRequestTabState();
}

class _SuppliesRequestTabState extends State<SuppliesRequestTab> {
  final List<SupplyRequest> _requests = [
    SupplyRequest(id: "REQ-001", itemName: "Latex Gloves (M)", quantity: 50, supplier: "DentalCare Supplies", status: "Pending", date: "20 Dec 2024"),
    SupplyRequest(id: "REQ-002", itemName: "Anesthetic Vials", quantity: 100, supplier: "Medipro Ltd.", status: "Approved", date: "18 Dec 2024"),
    SupplyRequest(id: "REQ-003", itemName: "Surgical Masks", quantity: 20, supplier: "Global Health", status: "Shipped", date: "15 Dec 2024"),
    SupplyRequest(id: "REQ-004", itemName: "Dental Mirrors", quantity: 10, supplier: "Precision Tools", status: "Received", date: "10 Dec 2024"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Supply Requests", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildActionHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(20.r),
              physics: const BouncingScrollPhysics(),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(_requests[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRequestDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildActionHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              " Create and track supply orders",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(SupplyRequest request) {
    Color statusColor;
    switch (request.status) {
      case 'Pending': statusColor = AppColors.warning; break;
      case 'Approved': statusColor = Colors.blue; break;
      case 'Shipped': statusColor = Colors.purple; break;
      case 'Received': statusColor = AppColors.success; break;
      default: statusColor = AppColors.textSecondary;
    }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request.id, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  request.status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(request.itemName, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, size: 14.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text("Quantity: ${request.quantity}", style: AppTextStyles.bodySmall),
              const Spacer(),
              Icon(Icons.business_outlined, size: 14.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(request.supplier, style: AppTextStyles.bodySmall),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Requested: ${request.date}", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              if (request.status == 'Shipped')
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Marked as Received")));
                  },
                  child: Text("Mark Received", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text("New Supply Request", style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(hintText: "Item Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
            SizedBox(height: 12.h),
            TextField(keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Quantity", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
              hint: const Text("Select Supplier"),
              items: ["DentalCare Supplies", "Medipro Ltd.", "Global Health"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {},
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }
}
