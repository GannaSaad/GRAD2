import 'package:flutter/material.dart';
import 'core/core/utils/app_colors.dart';
import 'core/core/utils/app_textstyles.dart';
import 'core/core/utils/app_constants.dart';

class SimpleHome extends StatelessWidget {
  const SimpleHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dentix',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppConstants.paddingM),
                Text(
                  'Modern dental care, simplified.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppConstants.paddingXL),
                Container(
                  padding: EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: AppConstants.elevationLow * 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'App is ready to run!\nThe Dentix theme is working correctly.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
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