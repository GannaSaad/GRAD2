import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/core/utils/app_colors.dart';
import '../../../../core/core/utils/app_textstyles.dart';

class DentalChart extends StatelessWidget {
  final Function(int)? onToothTap;
  final Set<int> highlightedTeeth;
  final int? selectedTooth;

  const DentalChart({
    super.key,
    this.onToothTap,
    this.highlightedTeeth = const {},
    this.selectedTooth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildJaw("Upper Jaw", 1, 16),
        SizedBox(height: 20.h),
        _buildJaw("Lower Jaw", 17, 32),
      ],
    );
  }

  Widget _buildJaw(String title, int start, int end) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(title, style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(end - start + 1, (index) {
              int toothId = start + index;
              bool isSelected = selectedTooth == toothId;
              bool isHighlighted = highlightedTeeth.contains(toothId);

              return GestureDetector(
                onTap: () => onToothTap?.call(toothId),
                child: Container(
                  width: 35.r,
                  height: 45.r,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryBlue 
                        : (isHighlighted ? AppColors.primaryBlueSoft : AppColors.backgroundPrimary),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.borderSoft,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.brightness_7_outlined, // Simplified tooth icon
                        size: 16.r,
                        color: isSelected ? Colors.white : AppColors.primaryBlue,
                      ),
                      Text(
                        "$toothId",
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
