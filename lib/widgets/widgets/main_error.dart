
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/core/utils/app_colors.dart';
import '../../core/core/utils/app_textstyles.dart';
import '../../core/core/utils/cubit/theme_cubit.dart';
import 'custom_elevated_button.dart';

class MainError extends StatelessWidget {
  final String? eMessage;
  final VoidCallback? onPress;
  MainError({super.key, required this.eMessage, this.onPress});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeCubit.isDark();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          eMessage!,
          style: isDark 
            ? AppTextStyles.medium14PrimaryDark.copyWith(color: AppColors.whiteColor)
            : AppTextStyles.medium14PrimaryDark,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        CustomElevatedButton(
          buttonText: 'Retry',
          onPressed: onPress ?? () {},
          backgroundColor: AppColors.primaryColor,
        ),
      ],
    );
  }
}
