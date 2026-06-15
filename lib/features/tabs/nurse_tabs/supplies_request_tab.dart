import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/request_entity.dart';
import '../../../domain/entities/supplier_entity.dart';
import '../../../domain/repos/auth_repo.dart';
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
  final _notesController = TextEditingController();
  final _clinicPhoneController = TextEditingController(); // Added
  final _clinicAddressController = TextEditingController(); // Added
  DateTime? _selectedNeededBy;
  String? _selectedCompany;
  String? _selectedSupplierId;

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
                    return _buildEmptyState();
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64.r, color: AppColors.borderMedium),
          SizedBox(height: 16.h),
          Text("No requests found", style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary)),
        ],
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
              " Create and track supply orders for the clinic",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestEntity request) {
    Color statusColor;
    switch (request.status.toLowerCase()) {
      case 'pending': case 'new': statusColor = Colors.blue; break;
      case 'accepted': statusColor = AppColors.success; break;
      case 'preparing': statusColor = Colors.purple; break;
      case 'shipped': statusColor = Colors.orange; break;
      case 'delivered': case 'received': statusColor = AppColors.primaryBlue; break;
      case 'delayed': statusColor = AppColors.error; break;
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
            color: AppColors.shadowColor.withValues(alpha: 0.05),
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
              Text("ID: ${request.id.length > 6 ? request.id.substring(request.id.length - 6).toUpperCase() : request.id.toUpperCase()}", 
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
              Text("Qty: ${request.quantity}", style: AppTextStyles.bodySmall),
              const Spacer(),
              Icon(Icons.business_outlined, size: 14.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(request.supplier, style: AppTextStyles.bodySmall),
            ],
          ),
          if (request.neededBy != null) ...[
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(Icons.event_available_outlined, size: 14.r, color: AppColors.error),
                SizedBox(width: 4.w),
                Text(
                  "Needed by: ${DateFormat('dd MMM yyyy').format(request.neededBy!)}",
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          if (request.notes != null && request.notes!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              "Note: ${request.notes}",
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Requested: ${DateFormat('dd MMM yyyy').format(request.date)}", 
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
              if (request.status.toLowerCase() != 'received' && request.status.toLowerCase() != 'delivered')
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          backgroundColor: AppColors.backgroundPrimary,
          title: Text("New Supply Request", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(_itemNameController, "Item Name", Icons.inventory_2_outlined),
                SizedBox(height: 16.h),
                _buildDialogField(_quantityController, "Quantity", Icons.format_list_numbered, keyboardType: TextInputType.number),
                SizedBox(height: 16.h),
                _buildDialogField(_clinicPhoneController, "Clinic Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone),
                SizedBox(height: 16.h),
                _buildDialogField(_clinicAddressController, "Clinic Address", Icons.location_on_outlined),
                SizedBox(height: 16.h),
                
                // 1. SELECT COMPANY
                DropdownButtonFormField<String>(
                  decoration: _getDropdownDecoration("Select Company", Icons.business_outlined),
                  items: ["DentalCare Supplies", "Medipro Ltd.", "Global Health"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      _selectedCompany = val;
                      _selectedSupplierId = null;
                    });
                  },
                ),
                SizedBox(height: 16.h),

                // 2. SELECT CONTACT PERSON (Filtered by Company)
                if (_selectedCompany != null)
                  FutureBuilder<List<SupplierEntity>>(
                    future: getIt<AuthRepo>().getSuppliersByCompany(_selectedCompany!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final companyContacts = snapshot.data ?? [];
                      
                      return DropdownButtonFormField<String>(
                        decoration: _getDropdownDecoration("Select Contact Person", Icons.person_outline),
                        hint: Text(companyContacts.isEmpty ? "No contacts found" : "Select Contact"),
                        items: companyContacts.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        )).toList(),
                        onChanged: (val) {
                          setDialogState(() => _selectedSupplierId = val);
                        },
                      );
                    },
                  ),
                
                SizedBox(height: 16.h),
                _buildDialogField(_notesController, "Notes (Optional)", Icons.note_alt_outlined),
                SizedBox(height: 16.h),
                
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => _selectedNeededBy = date);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSoft),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary, size: 20),
                        SizedBox(width: 12.w),
                        Text(
                          _selectedNeededBy == null ? "Needed By Date" : DateFormat('dd MMM yyyy').format(_selectedNeededBy!),
                          style: TextStyle(color: _selectedNeededBy == null ? AppColors.textTertiary : AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_itemNameController.text.isNotEmpty && 
                    _quantityController.text.isNotEmpty && 
                    _selectedCompany != null &&
                    _clinicPhoneController.text.isNotEmpty &&
                    _clinicAddressController.text.isNotEmpty) {
                  _viewModel.createRequest(
                    itemName: _itemNameController.text,
                    quantity: int.parse(_quantityController.text),
                    supplier: _selectedCompany!, 
                    supplierId: _selectedSupplierId, 
                    notes: _notesController.text,
                    neededBy: _selectedNeededBy,
                    clinicPhone: _clinicPhoneController.text.trim(),
                    clinicAddress: _clinicAddressController.text.trim(),
                  );
                  Navigator.pop(context);
                  _itemNameController.clear();
                  _quantityController.clear();
                  _notesController.clear();
                  _clinicPhoneController.clear();
                  _clinicAddressController.clear();
                  _selectedNeededBy = null;
                  _selectedCompany = null;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: const Text("Send Request", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getDropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderSoft)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderSoft)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderSoft)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderSoft)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryBlue)),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _clinicPhoneController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }
}
