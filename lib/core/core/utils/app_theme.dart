import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
import 'app_textstyles.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.whiteColor,
    bottomNavigationBarTheme:BottomNavigationBarThemeData(
      backgroundColor:AppColors.whiteColor,

    ),
    textTheme:TextTheme(
        headlineLarge:AppTextStyles.normal16Grey,
        headlineMedium:AppTextStyles.medium14black,
        headlineSmall:AppTextStyles.semiBold16White.copyWith(color:AppColors.blackColor)
    ),
    primaryColor:AppColors.whiteColor,

  );
  static final ThemeData DarkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.darkBackground,
    bottomNavigationBarTheme:BottomNavigationBarThemeData(
        backgroundColor:AppColors.darkCard
    ),
    textTheme:TextTheme(
        headlineLarge:AppTextStyles.normal16Grey,
        headlineMedium:AppTextStyles.medium14black.copyWith(color: AppColors.whiteColor),
        headlineSmall:AppTextStyles.semiBold16White
    ),
    primaryColor:AppColors.darkCard,

  );
}
