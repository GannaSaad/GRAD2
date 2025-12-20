import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/app_constants.dart';
import '../../widgets/widgets/dentix_logo.dart';

class PatientLoginOrGuestScreen extends StatelessWidget {
  const PatientLoginOrGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary,
            size: AppConstants.iconM,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstants.screenMargin,
          ),
          child: Column(
            children: [
              SizedBox(height: AppConstants.paddingXL),
              
              // Header
              Column(
                children: [
                  DentixLogo(fontSize: 24.sp),
                  SizedBox(height: AppConstants.paddingL),
                  Text(
                    'Patient Access',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingS),
                  Text(
                    'Sign in to your account or continue as a guest',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Placeholder content
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppConstants.cardPadding),
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
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 48.w,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(height: AppConstants.paddingM),
                    Text(
                      'Coming Soon',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppConstants.paddingS),
                    Text(
                      'Patient login and guest access features are under development.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              SizedBox(height: AppConstants.paddingXL),
            ],
          ),
        ),
      ),
    );
  }
}