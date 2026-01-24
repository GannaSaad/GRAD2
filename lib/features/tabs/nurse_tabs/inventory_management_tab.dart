import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/inventory_entity.dart';
import 'cubit/inventory_view_model.dart';

class InventoryManagementTab extends StatefulWidget {
  const InventoryManagementTab({super.key});

  @override
  State<InventoryManagementTab> createState() => _InventoryManagementTabState();
}

class _InventoryManagementTabState extends State<InventoryManagementTab> {
  late InventoryViewModel _viewModel;
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<InventoryViewModel>();
    _viewModel.getInventory();
    _viewModel.seedInventoryIfEmpty(); // Ensures database has tools on first run
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
          title: Text("Inventory Management", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: BlocBuilder<InventoryViewModel, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) return const Center(child: CircularProgressIndicator());
            if (state is InventoryFailure) return Center(child: Text(state.message));
            
            List<InventoryEntity> items = [];
            if (state is InventorySuccess) {
              items = _filterStatus == null 
                  ? state.items 
                  : state.items.where((i) => i.status == _filterStatus).toList();
            }

            return Column(
              children: [
                _buildSummaryStats(state is InventorySuccess ? state.items : []),
                SizedBox(height: 16.h),
                Expanded(
                  child: items.isEmpty 
                      ? Center(child: Text("No items in inventory", style: AppTextStyles.bodyMedium))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) => _buildInventoryCard(items[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<InventoryEntity> allItems) {
    int lowStock = allItems.where((i) => i.status == 'Low Stock').length;
    int outOfStock = allItems.where((i) => i.status == 'Out of Stock').length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBox("Total", "${allItems.length}", AppColors.primaryBlue, null),
          _buildStatBox("Low", "$lowStock", AppColors.warning, 'Low Stock'),
          _buildStatBox("Out", "$outOfStock", AppColors.error, 'Out of Stock'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color, String? filter) {
    bool isSelected = _filterStatus == filter && filter != null;
    return GestureDetector(
      onTap: filter == null ? null : () => setState(() => _filterStatus = isSelected ? null : filter),
      child: Container(
        width: 110.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleLarge.copyWith(color: color, fontWeight: FontWeight.bold)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(InventoryEntity item) {
    Color statusColor = AppColors.success;
    if (item.status == 'Low Stock') statusColor = AppColors.warning;
    if (item.status == 'Out of Stock') statusColor = AppColors.error;

    double progress = item.totalQuantity > 0 ? item.currentQuantity / item.totalQuantity : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: const Offset(0, 4))],
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
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                child: Text(item.status, style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text("${item.currentQuantity} / ${item.totalQuantity} ${item.unit}", 
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryBlueLight.withValues(alpha: 0.3),
            color: statusColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}
