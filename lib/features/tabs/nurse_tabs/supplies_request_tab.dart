import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/request_entity.dart';
import 'cubit/request_view_model.dart';

class SuppliesRequestTab extends StatefulWidget {
  const SuppliesRequestTab({super.key});

  @override
  State<SuppliesRequestTab> createState() => _SuppliesRequestTabState();
}

class _SuppliesRequestTabState extends State<SuppliesRequestTab> {
  final RequestViewModel _viewModel = getIt<RequestViewModel>();
  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    _viewModel.fetchRequests();
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
          title: Text("Supply Requests", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildActionHeader(),
            Expanded(
              child: BlocBuilder<RequestViewModel, RequestState>(
                builder: (context, state) {
                  if (state is RequestLoading) return const Center(child: CircularProgressIndicator());
                  
                  List<RequestEntity> requests = [];
                  if (state is RequestSuccess) {
                    requests = state.requests;
                  } else if (state is RequestAddedSuccessfully) {
                    requests = state.requests;
                  }

                  if (requests.isEmpty) {
                    return Center(child: Text("No requests found", style: AppTextStyles.bodyMedium));
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.all(20.r),
                    physics: const BouncingScrollPhysics(),
                    itemCount: requests.length,
                    itemBuilder: (context, index) => _buildRequestCard(requests[index]),
                  );
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
      ),
    );
  }

  Widget _buildActionHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft.withValues(alpha: 0.3),
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

  Widget _buildRequestCard(RequestEntity request) {
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
              Text("ID: ${request.id.substring(request.id.length > 6 ? request.id.length - 6 : 0)}", 
                style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
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
              Text("Requested: ${DateFormat('dd MMM yyyy').format(request.date)}", 
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              if (request.status != 'Received')
                SizedBox(
                  height: 30.h,
                  child: OutlinedButton(
                    onPressed: () => _viewModel.updateRequestStatus(request.id, 'Received'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      "Mark Arrived",
                      style: TextStyle(fontSize: 10.sp, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
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
            TextField(controller: _itemNameController, decoration: InputDecoration(hintText: "Item Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
            SizedBox(height: 12.h),
            TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: "Quantity", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)))),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
              hint: const Text("Select Supplier"),
              items: ["DentalCare Supplies", "Medipro Ltd.", "Global Health"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => _selectedSupplier = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () {
              if (_itemNameController.text.isNotEmpty && _quantityController.text.isNotEmpty && _selectedSupplier != null) {
                _viewModel.createRequest(
                  itemName: _itemNameController.text,
                  quantity: int.parse(_quantityController.text),
                  supplier: _selectedSupplier!,
                );
                Navigator.pop(context);
                _itemNameController.clear();
                _quantityController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.primaryGoldLight, // Text color set to Beige
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text("Send Request", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
