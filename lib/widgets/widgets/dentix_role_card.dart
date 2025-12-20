import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/app_constants.dart';

class DentixRoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const DentixRoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.paddingM), // Tighter spacing
      child: Card(
        color: AppColors.cardBackground,
        elevation: AppConstants.elevationLow,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r), // 18-22 range
          side: BorderSide(
            color: AppColors.borderSoft,
            width: 0.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingM), // Tighter padding
            child: Row(
              children: [
                // Icon container with soft blue background, radius 14-16
                Container(
                  width: 56.w, // Slightly smaller
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueSoft, // Soft blue from theme
                    borderRadius: BorderRadius.circular(15.r), // 14-16 range
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryBlue,
                    size: 26.w, // Slightly smaller
                  ),
                ),
                
                SizedBox(width: AppConstants.paddingM),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith( // Smaller title
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingXS / 2), // Tighter spacing
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith( // Smaller description
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(width: AppConstants.paddingS),
                
                // Chevron - aligned center vertically
                Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textTertiary,
                    size: 14.w, // Smaller chevron
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}