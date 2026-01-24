import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import '../../../../core/core/utils/app_colors.dart';
import '../../../../core/core/utils/app_textstyles.dart';

class JawChart extends StatelessWidget {
  final Function(int)? onToothTap;
  final Map<int, Map<String, dynamic>> toothData; 
  final int? selectedTooth;

  const JawChart({
    super.key,
    this.onToothTap,
    this.toothData = const {},
    this.selectedTooth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          _buildRealisticJaw(true), // Upper
          SizedBox(height: 40.h),
          const Divider(indent: 40, endIndent: 40),
          SizedBox(height: 40.h),
          _buildRealisticJaw(false), // Lower
        ],
      ),
    );
  }

  Widget _buildRealisticJaw(bool isUpper) {
    return Column(
      children: [
        Text(isUpper ? "UPPER JAW" : "LOWER JAW", 
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: AppColors.textTertiary
          )),
        SizedBox(height: 30.h),
        SizedBox(
          height: 160.h,
          width: 340.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(16, (index) {
              int toothId = isUpper ? (index + 1) : (32 - index);
              return _buildAnatomicalTooth(toothId, index, isUpper);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildAnatomicalTooth(int toothId, int index, bool isUpper) {
    // Advanced Elliptical Pathing for anatomical arch
    double t = index / 15.0; 
    double angle = math.pi + (t * math.pi); 
    
    double a = 140.w; 
    double b = 100.h; 
    
    double x = 170.w + a * math.cos(angle);
    double y = isUpper ? (b + b * math.sin(angle)) : (b * -math.sin(angle));

    String? status = toothData[toothId]?['status'];
    bool isSelected = selectedTooth == toothId;

    // COLOR LOGIC: Green for Completed, Red for In Progress
    Color toothColor = AppColors.backgroundPrimary;
    if (status == 'Completed') {
      toothColor = Colors.green.shade600;
    } else if (status == 'In Progress') {
      toothColor = Colors.red.shade600;
    }

    return Positioned(
      left: x - 18.r,
      top: y - 22.r,
      child: GestureDetector(
        onTap: () => onToothTap?.call(toothId),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : toothColor,
                borderRadius: _getToothShape(toothId),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.borderMedium,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: AppColors.primaryBlue.withOpacity(0.4), blurRadius: 12, spreadRadius: 2)
                ] : [],
              ),
              child: Center(
                child: Icon(
                  _getToothIcon(toothId),
                  size: 18.r,
                  color: isSelected || (status != null) ? Colors.white : AppColors.primaryBlue.withOpacity(0.6),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "$toothId",
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 9.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryBlue : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BorderRadius _getToothShape(int id) {
    if ((id >= 1 && id <= 3) || (id >= 14 && id <= 19) || (id >= 30 && id <= 32)) {
      return BorderRadius.circular(8.r);
    }
    return BorderRadius.circular(12.r);
  }

  IconData _getToothIcon(int id) {
    if ((id >= 1 && id <= 3) || (id >= 14 && id <= 19) || (id >= 30 && id <= 32)) {
      return Icons.grid_view_rounded;
    }
    return Icons.rectangle_rounded;
  }
}
