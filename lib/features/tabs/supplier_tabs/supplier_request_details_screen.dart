import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dentex_clean/api/config/di/di.dart';
import 'package:dentex_clean/core/core/utils/app_colors.dart';
import 'package:dentex_clean/core/core/utils/app_textstyles.dart';
import 'package:dentex_clean/domain/entities/request_entity.dart';
import 'package:dentex_clean/domain/use_cases/update_request_status_use_case.dart';

class SupplierRequestDetailsScreen extends StatefulWidget {
  final RequestEntity request;

  const SupplierRequestDetailsScreen({super.key, required this.request});

  @override
  State<SupplierRequestDetailsScreen> createState() => _SupplierRequestDetailsScreenState();
}

class _SupplierRequestDetailsScreenState extends State<SupplierRequestDetailsScreen> {
  late String _currentStatus;
  bool _isProcessing = false;
  final _updateUseCase = getIt<UpdateRequestStatusUseCase>();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
  }

  Future<void> _handleUpdate(String newStatus) async {
    if (_currentStatus == newStatus || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _updateUseCase.call(widget.request.id, newStatus);

      if (mounted) {
        setState(() {
          _currentStatus = newStatus;
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Request status updated to $newStatus"),
            backgroundColor: _getStatusColor(newStatus),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(24.r),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update: ${e.toString()}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: Text(
          "Request Details",
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                SizedBox(height: 24.h),
                _buildClinicInfoSection(),
                SizedBox(height: 24.h),
                _buildItemsSection(),
                SizedBox(height: 24.h),
                _buildAdditionalInfoSection(),
                SizedBox(height: 32.h),
                _buildActionsSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: _getStatusColor(_currentStatus).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(_currentStatus).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Current Status", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              SizedBox(height: 4.h),
              Text(
                _currentStatus,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_currentStatus),
                ),
              ),
            ],
          ),
          _buildStatusIcon(_currentStatus),
        ],
      ),
    );
  }

  Widget _buildClinicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Requester & Delivery Information"),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Column(
            children: [
              _buildInfoRow(Icons.medical_services_rounded, "Requester", widget.request.clinicName ?? "Unknown"),
              const Divider(height: 32, color: AppColors.borderSoft),
              _buildInfoRow(Icons.phone_rounded, "Clinic Phone", widget.request.clinicPhone ?? "N/A"),
              const Divider(height: 32, color: AppColors.borderSoft),
              _buildInfoRow(Icons.location_on_rounded, "Delivery Address", widget.request.clinicAddress ?? "N/A"),
              const Divider(height: 32, color: AppColors.borderSoft),
              _buildInfoRow(Icons.calendar_today_rounded, "Request Date", "${widget.request.date.day}/${widget.request.date.month}/${widget.request.date.year}"),
              const Divider(height: 32, color: AppColors.borderSoft),
              _buildInfoRow(
                Icons.event_available_rounded, 
                "Needed By", 
                widget.request.neededBy != null 
                    ? "${widget.request.neededBy!.day}/${widget.request.neededBy!.month}/${widget.request.neededBy!.year}"
                    : "As soon as possible"
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Requested Items"),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(color: AppColors.primaryBlueSoft, shape: BoxShape.circle),
                child: Icon(Icons.inventory_2, color: AppColors.primaryBlue, size: 20.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(widget.request.itemName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ),
              Text(
                "${widget.request.quantity} Units",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Notes"),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Text(
            widget.request.notes ?? "No additional notes provided.",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Update Status"),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [
            _buildActionButton("Accept Request", AppColors.success, Icons.check_circle_outline, "Accepted"),
            _buildActionButton("Mark as Preparing", Colors.purple, Icons.pending_actions_rounded, "Preparing"),
            _buildActionButton("Mark as Shipped", Colors.orange, Icons.local_shipping_outlined, "Shipped"),
            _buildActionButton("Mark as Delivered", AppColors.primaryBlue, Icons.verified_outlined, "Delivered"),
            _buildActionButton("Mark as Delayed", AppColors.error, Icons.warning_amber_rounded, "Delayed"),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primaryGold),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
              Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, String statusValue) {
    bool isSelected = _currentStatus == statusValue;
    return SizedBox(
      width: (1.sw - 60.w) / 2,
      child: Material(
        color: color.withOpacity(isSelected ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: () => _handleUpdate(statusValue),
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.3),
                width: isSelected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26.r),
                SizedBox(height: 10.h),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New': case 'Pending': return Colors.blue;
      case 'Accepted': return AppColors.success;
      case 'Preparing': return Colors.purple;
      case 'Shipped': return Colors.orange;
      case 'Delivered': return AppColors.primaryBlue;
      case 'Delayed': return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildStatusIcon(String status) {
    final color = _getStatusColor(status);
    IconData icon;
    switch (status) {
      case 'New': case 'Pending': icon = Icons.fiber_new_rounded; break;
      case 'Accepted': icon = Icons.check_circle_outline; break;
      case 'Preparing': icon = Icons.pending_actions_rounded; break;
      case 'Shipped': icon = Icons.local_shipping_outlined; break;
      case 'Delivered': icon = Icons.verified_outlined; break;
      case 'Delayed': icon = Icons.warning_amber_rounded; break;
      default: icon = Icons.info_outline;
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(status),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 30.r),
      ),
    );
  }
}
