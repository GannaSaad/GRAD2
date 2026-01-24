import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../api/config/di/di.dart';
import '../../../core/core/utils/app_colors.dart';
import '../../../core/core/utils/app_textstyles.dart';
import '../../../domain/entities/inventory_entity.dart';
import '../../../widgets/widgets/custom_elevated_button.dart';
import 'cubit/clinical_prep_view_model.dart';

class NursePatientDetailsScreen extends StatefulWidget {
  final String patientName;
  final String patientImage;

  const NursePatientDetailsScreen({
    super.key,
    required this.patientName,
    required this.patientImage,
  });

  @override
  State<NursePatientDetailsScreen> createState() => _NursePatientDetailsScreenState();
}

class _NursePatientDetailsScreenState extends State<NursePatientDetailsScreen> {
  late ClinicalPrepViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClinicalPrepViewModel>();
    _viewModel.loadInventory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Clinical Preparation", style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocListener<ClinicalPrepViewModel, ClinicalPrepState>(
          listener: (context, state) {
            if (state is ClinicalPrepInitial) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Clinical setup complete. Inventory updated!"), backgroundColor: Colors.green),
              );
            } else if (state is ClinicalPrepFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: ${state.message}"), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<ClinicalPrepViewModel, ClinicalPrepState>(
            builder: (context, state) {
              List<InventoryEntity> inventory = [];
              Set<String> pickedIds = {};
              bool isLoading = state is ClinicalPrepLoading;

              if (state is ClinicalPrepSuccess) {
                inventory = state.inventory;
                pickedIds = state.pickedItemIds;
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientHeader(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader("Scheduled Treatment"),
                    SizedBox(height: 12.h),
                    _buildTreatmentCard(),
                    SizedBox(height: 32.h),
                    _buildSectionHeader("Pick Materials from Inventory"),
                    SizedBox(height: 8.h),
                    Text("Select only the items needed for this procedure", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                    SizedBox(height: 16.h),

                    if (isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (inventory.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Text("Inventory is empty. Add tools in the Inventory tab.",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent)),
                        ),
                      )
                    else
                      _buildRealMaterialsChecklist(inventory, pickedIds),

                    SizedBox(height: 32.h),
                    _buildSectionHeader("Doctor's Special Instructions"),
                    SizedBox(height: 12.h),
                    _buildNotesCard(),
                    SizedBox(height: 40.h),

                    CustomElevatedButton(
                      buttonText: pickedIds.isEmpty ? "Select Materials" : "Confirm & Deduct Inventory",
                      onPressed: (pickedIds.isEmpty || isLoading) ? null : () => _viewModel.confirmReadiness(),
                      backgroundColor: pickedIds.isEmpty ? AppColors.grayColor : AppColors.primaryBlue,
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final String initials = widget.patientName.isNotEmpty
        ? widget.patientName.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
        : "?";

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundColor: AppColors.primaryBlueSoft,
            child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.patientName, style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              Text("Preparation for treatment", style: AppTextStyles.labelSmall.copyWith(color: AppColors.primaryGold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildTreatmentCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueSoft.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlueLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services_outlined, color: AppColors.primaryBlue),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Room Setup", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text("Ensure all selected items are sterilized and ready.", style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealMaterialsChecklist(List<InventoryEntity> inventory, Set<String> pickedIds) {
    return Column(
      children: inventory.map((item) {
        bool isPicked = pickedIds.contains(item.id);
        bool isOutOfStock = item.currentQuantity <= 0;

        return GestureDetector(
          onTap: isOutOfStock ? null : () => _viewModel.togglePick(item.id),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isOutOfStock ? Colors.grey.shade100 : (isPicked ? AppColors.successLight : AppColors.cardBackground),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isPicked ? AppColors.success : AppColors.borderSoft),
            ),
            child: Row(
              children: [
                Icon(
                  isPicked ? Icons.check_circle : (isOutOfStock ? Icons.block : Icons.inventory_2_outlined),
                  color: isPicked ? AppColors.success : (isOutOfStock ? Colors.grey : AppColors.primaryBlue),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: isOutOfStock ? Colors.grey : AppColors.textPrimary)),
                      Text("Available: ${item.currentQuantity} ${item.unit}", style: AppTextStyles.labelSmall.copyWith(color: isOutOfStock ? Colors.red : AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (isPicked)
                  Text("PICKED", style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Text(
        "Prepare clinical station according to standard hygiene protocols.",
        style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.warning),
      ),
    );
  }
}