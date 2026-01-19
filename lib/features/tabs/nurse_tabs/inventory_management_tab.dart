import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';

class InventoryItem {
  final String name;
  final String unit;
  final int currentQuantity;
  final int totalQuantity;
  final String status; // 'In Stock', 'Low Stock', 'Out of Stock'

  InventoryItem({
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.totalQuantity,
    required this.status,
  });
}

class InventoryManagementTab extends StatefulWidget {
  const InventoryManagementTab({super.key});

  @override
  State<InventoryManagementTab> createState() => _InventoryManagementTabState();
}

class _InventoryManagementTabState extends State<InventoryManagementTab> {
  String? _filterStatus; // null means all, otherwise 'Low Stock' or 'Out of Stock'

  // Mock inventory data
  final List<InventoryItem> _fullInventory = [
    InventoryItem(name: "Latex Gloves (M)", unit: "Boxes", currentQuantity: 12, totalQuantity: 100, status: "Low Stock"),
    InventoryItem(name: "Dental Mirror #4", unit: "Units", currentQuantity: 45, totalQuantity: 50, status: "In Stock"),
    InventoryItem(name: "Composite Resin (A2)", unit: "Capsules", currentQuantity: 8, totalQuantity: 50, status: "Low Stock"),
    InventoryItem(name: "Anesthetic Vials", unit: "Vials", currentQuantity: 120, totalQuantity: 200, status: "In Stock"),
    InventoryItem(name: "Surgical Masks", unit: "Boxes", currentQuantity: 2, totalQuantity: 50, status: "Low Stock"),
    InventoryItem(name: "High-Volume Suction", unit: "Tips", currentQuantity: 0, totalQuantity: 100, status: "Out of Stock"),
    InventoryItem(name: "Dental Bibs", unit: "Rolls", currentQuantity: 15, totalQuantity: 20, status: "In Stock"),
  ];

  @override
  Widget build(BuildContext context) {
    List<InventoryItem> filteredList = _filterStatus == null 
        ? _fullInventory 
        : _fullInventory.where((item) => item.status == _filterStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Inventory Management", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
        centerTitle: true,
        actions: [
          if (_filterStatus != null)
            IconButton(
              icon: const Icon(Icons.filter_list_off, color: AppColors.primaryBlue),
              onPressed: () => setState(() => _filterStatus = null),
            ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryStats(),
          SizedBox(height: 16.h),
          if (_filterStatus != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Text("Showing: ", style: AppTextStyles.labelSmall),
                  Text(_filterStatus!, style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                ],
              ),
            ),
          SizedBox(height: 12.h),
          Expanded(
            child: filteredList.isEmpty 
                ? Center(child: Text("No items match this filter", style: AppTextStyles.bodyMedium))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildInventoryCard(filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    int lowStockCount = _fullInventory.where((i) => i.status == 'Low Stock').length;
    int outOfStockCount = _fullInventory.where((i) => i.status == 'Out of Stock').length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBox("Total Items", "${_fullInventory.length}", AppColors.primaryBlue, null),
          _buildStatBox("Low Stock", "$lowStockCount", AppColors.warning, 'Low Stock'),
          _buildStatBox("Out of Stock", "$outOfStockCount", AppColors.error, 'Out of Stock'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, String? filter) {
    bool isSelected = _filterStatus == filter && filter != null;
    return GestureDetector(
      onTap: filter == null ? null : () => setState(() => _filterStatus = isSelected ? null : filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected ? Border.all(color: color, width: 2) : Border.all(color: Colors.transparent),
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
            Text(value, style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.h),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    Color statusColor;
    switch (item.status) {
      case 'In Stock':
        statusColor = AppColors.success;
        break;
      case 'Low Stock':
        statusColor = AppColors.warning;
        break;
      case 'Out of Stock':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    double progress = item.totalQuantity > 0 ? item.currentQuantity / item.totalQuantity : 0;

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
              Text(item.name, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.status,
                  style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text("${item.currentQuantity} / ${item.totalQuantity}", 
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              SizedBox(width: 4.w),
              Text(item.unit, style: AppTextStyles.bodySmall),
            ],
          ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryBlueLight.withOpacity(0.3),
            color: statusColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}
