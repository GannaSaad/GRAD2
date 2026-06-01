import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dentex_clean/api/config/di/di.dart';
import 'package:dentex_clean/core/core/utils/app_colors.dart';
import 'package:dentex_clean/core/core/utils/app_textstyles.dart';
import 'package:dentex_clean/domain/entities/request_entity.dart';
import 'package:dentex_clean/domain/repos/request_repo.dart';
import 'package:dentex_clean/features/auth/auth_cubit/auth_cubit.dart';
import 'supplier_request_details_screen.dart';

class SupplierHomeTab extends StatefulWidget {
  const SupplierHomeTab({super.key});

  @override
  State<SupplierHomeTab> createState() => _SupplierHomeTabState();
}

class _SupplierHomeTabState extends State<SupplierHomeTab> {
  final _requestRepo = getIt<RequestRepo>();

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthCubit>().currentUser;
    // CONNECTION: The supplier user's companyId links them to the requests
    final companyId = user?.companyId ?? "";
    final displayName = user?.fullName ?? "Partner";

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: StreamBuilder<List<RequestEntity>>(
          stream: _requestRepo.getAllRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
            }

            final allRequests = snapshot.data ?? [];
            
            // FILTER: Show all requests where the target 'supplier' (Company) matches this user's companyId
            final requests = allRequests.where((r) => r.supplier == companyId).toList();
            
            int newCount = requests.where((r) {
              final status = r.status.toLowerCase();
              return status == "new" || status == "pending";
            }).length;
            int acceptedCount = requests.where((r) {
              final status = r.status.toLowerCase();
              return status == "accepted" || status == "preparing";
            }).length;
            int shippedCount = requests.where((r) => r.status.toLowerCase() == "shipped").length;
            int deliveredCount = requests.where((r) {
              final status = r.status.toLowerCase();
              return status == "delivered" || status == "received";
            }).length;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(displayName, companyId),
                  SizedBox(height: 32.h),
                  _buildSectionTitle("Operations Summary"),
                  SizedBox(height: 16.h),
                  _buildSummaryGrid(newCount, acceptedCount, shippedCount, deliveredCount),
                  SizedBox(height: 40.h),
                  _buildRecentRequestsHeader(),
                  SizedBox(height: 16.h),
                  _buildRecentRequestsList(requests.take(5).toList()),
                  SizedBox(height: 40.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String company) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Greetings, $userName", style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
            Text(
              company.isNotEmpty ? company : "Logistics Partner", 
              style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.notifications_none_rounded, color: AppColors.primaryBlue, size: 28.r),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildSummaryGrid(int newReq, int accepted, int shipped, int delivered) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard("New Requests", newReq.toString().padLeft(2, '0'), Icons.add_shopping_cart, Colors.blue)),
            SizedBox(width: 16.w),
            Expanded(child: _buildSummaryCard("Accepted", accepted.toString().padLeft(2, '0'), Icons.assignment_turned_in_outlined, AppColors.success)),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildSummaryCard("Shipped", shipped.toString().padLeft(2, '0'), Icons.local_shipping_outlined, Colors.orange)),
            SizedBox(width: 16.w),
            Expanded(child: _buildSummaryCard("Delivered", delivered.toString().padLeft(2, '0'), Icons.verified_outlined, AppColors.primaryBlue)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [BoxShadow(color: AppColors.shadowColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 22.r),
          ),
          SizedBox(height: 16.h),
          Text(count, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Latest Inventory Needs", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
        Text("View History", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentRequestsList(List<RequestEntity> requests) {
    if (requests.isEmpty) {
      return Center(child: Text("No recent requests for your company", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
    }
    return Column(
      children: requests.map((req) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupplierRequestDetailsScreen(request: req),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  _buildOrderIcon(req.status),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.clinicName ?? "Unknown Clinic", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text("${req.itemName} (${req.quantity})", style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                  _buildStatusTag(req.status),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildOrderIcon(String status) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(color: AppColors.primaryBlueSoft, shape: BoxShape.circle),
      child: Icon(Icons.inventory_2, color: AppColors.primaryBlue, size: 20.r),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = AppColors.primaryBlue;
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'new' || lowerStatus == 'pending') color = Colors.blue;
    if (lowerStatus == 'shipped') color = Colors.orange;
    if (lowerStatus == 'accepted' || lowerStatus == 'preparing') color = AppColors.success;
    if (lowerStatus == 'delivered' || lowerStatus == 'received') color = AppColors.primaryBlue;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
      child: Text(status, style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.bold)),
    );
  }
}
