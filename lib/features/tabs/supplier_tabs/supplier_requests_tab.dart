import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dentex_clean/api/config/di/di.dart';
import 'package:dentex_clean/core/core/utils/app_colors.dart';
import 'package:dentex_clean/core/core/utils/app_textstyles.dart';
import 'package:dentex_clean/domain/entities/request_entity.dart';
import 'package:dentex_clean/domain/repos/request_repo.dart';
import 'package:dentex_clean/features/auth/auth_cubit/auth_cubit.dart';
import 'supplier_request_details_screen.dart';

class SupplierRequestsTab extends StatefulWidget {
  const SupplierRequestsTab({super.key});

  @override
  State<SupplierRequestsTab> createState() => _SupplierRequestsTabState();
}

class _SupplierRequestsTabState extends State<SupplierRequestsTab> {
  String _selectedFilter = "All";
  final _requestRepo = getIt<RequestRepo>();
  
  final List<String> _filters = [
    "All", "New", "Accepted", "Preparing", "Shipped", "Delivered", "Delayed"
  ];

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;
    final companyId = user?.companyId ?? "Supplier";

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
              child: Text(
                "Inventory Requests",
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            _buildFilterBar(),
            Expanded(
              child: StreamBuilder<List<RequestEntity>>(
                stream: _requestRepo.getAllRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                  }
                  
                  final allRequests = snapshot.data ?? [];
                  final companyRequests = allRequests.where((r) => r.supplier == companyId).toList();

                  final filteredList = _selectedFilter == "All" 
                      ? companyRequests 
                      : companyRequests.where((r) {
                          final status = r.status.toLowerCase();
                          final filter = _selectedFilter.toLowerCase();
                          if (_selectedFilter == "New") {
                            return status == "new" || status == "pending";
                          }
                          return status == filter;
                        }).toList();

                  if (filteredList.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) => _buildRequestCard(filteredList[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((filter) {
          bool isSelected = _selectedFilter == filter;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestCard(RequestEntity req) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SupplierRequestDetailsScreen(request: req),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "From: ${req.clinicName ?? 'Unknown Clinic'}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold, 
                              color: AppColors.textPrimary
                            ),
                          ),
                          Text(
                            "ID: ${req.id.length > 8 ? req.id.substring(0, 8).toUpperCase() : req.id.toUpperCase()}",
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(req.status),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.inventory_2, size: 18.r, color: AppColors.primaryGold),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "${req.itemName} (${req.quantity} units)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                const Divider(color: AppColors.borderSoft),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12.r, color: AppColors.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          "${req.date.day}/${req.date.month}/${req.date.year}",
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                    if (req.neededBy != null)
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 12.r, color: AppColors.error),
                          SizedBox(width: 4.w),
                          Text(
                            "Due: ${req.neededBy!.day}/${req.neededBy!.month}",
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'new': case 'pending': color = Colors.blue; break;
      case 'accepted': color = AppColors.success; break;
      case 'preparing': color = Colors.purple; break;
      case 'shipped': color = Colors.orange; break;
      case 'delivered': color = AppColors.primaryBlue; break;
      case 'delayed': color = AppColors.error; break;
      default: color = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64.r, color: AppColors.borderMedium),
          SizedBox(height: 16.h),
          Text("No requests found", style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
