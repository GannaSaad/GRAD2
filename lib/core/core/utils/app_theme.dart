
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_textstyles.dart';
import 'app_constants.dart';

class AppTheme {
  // Dentix Light Theme - Healthcare-grade design system
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.light,
      primary: AppColors.primaryBlue,
      onPrimary: AppColors.whiteColor,
      secondary: AppColors.primaryBlueLight,
      onSecondary: AppColors.whiteColor,
      surface: AppColors.cardBackground,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.whiteColor,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    
    // App Bar Theme - Clean and flat
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: AppColors.transparentColor,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: AppTextStyles.titleLarge,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: AppColors.textPrimary,
        size: AppConstants.iconM,
      ),
    ),
    
    // Card Theme - Soft shadows and rounded corners
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: AppConstants.elevationLow,
      shadowColor: AppColors.shadowColor,
      surfaceTintColor: AppColors.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
    ),
    
    // Elevated Button Theme - Primary blue with rounded corners
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.whiteColor,
        elevation: AppConstants.elevationLow,
        shadowColor: AppColors.shadowColor,
        surfaceTintColor: AppColors.transparentColor,
        minimumSize: Size(double.infinity, AppConstants.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: AppTextStyles.buttonMedium,
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingL,
          vertical: AppConstants.paddingM,
        ),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColors.primaryBlueLight;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.borderSoft;
          }
          return AppColors.primaryBlue;
        }),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        textStyle: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primaryBlue,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        minimumSize: Size(double.infinity, AppConstants.buttonHeightMedium),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: AppTextStyles.buttonMedium.copyWith(
          color: AppColors.primaryBlue,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingL,
          vertical: AppConstants.paddingM,
        ),
      ),
    ),
    
    // Input Decoration Theme - Soft borders and calm focus
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppColors.borderSoft, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppColors.borderSoft, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingM,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPlaceholder,
      ),
      labelStyle: AppTextStyles.labelLarge,
      errorStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.error,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBackground,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: AppConstants.elevationMedium,
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      selectedColor: AppColors.primaryBlueSoft,
      labelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.chipRadius),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSoft,
      thickness: 1,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.textSecondary,
      size: AppConstants.iconM,
    ),
    
    // Primary Icon Theme
    primaryIconTheme: IconThemeData(
      color: AppColors.primaryBlue,
      size: AppConstants.iconM,
    ),
    
    // Text Theme - Complete typography system
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    
    // Primary Color
    primaryColor: AppColors.primaryBlue,
  );
  
  // Dentix Dark Theme - Medical-friendly dark mode
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    
    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      brightness: Brightness.dark,
      primary: AppColors.primaryBlueLight,
      onPrimary: AppColors.blackColor,
      secondary: AppColors.primaryBlue,
      onSecondary: AppColors.whiteColor,
      surface: AppColors.darkCard,
      onSurface: AppColors.whiteColor,
      error: AppColors.error,
      onError: AppColors.whiteColor,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.whiteColor,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: AppColors.transparentColor,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: AppTextStyles.titleLarge.copyWith(
        color: AppColors.whiteColor,
      ),
      centerTitle: false,
      iconTheme: IconThemeData(
        color: AppColors.whiteColor,
        size: AppConstants.iconM,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: AppConstants.elevationLow,
      shadowColor: AppColors.blackColor.withValues(alpha: 0.3),
      surfaceTintColor: AppColors.transparentColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingM,
        vertical: AppConstants.paddingS,
      ),
    ),
    
    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCard,
      selectedItemColor: AppColors.primaryBlueLight,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: AppConstants.elevationMedium,
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.primaryBlueLight,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    
    // Text Theme - Dark mode variants
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.whiteColor),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.whiteColor),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.whiteColor),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.whiteColor),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.whiteColor),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.whiteColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.whiteColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.whiteColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.textTertiary),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
    ),
    
    // Primary Color
    primaryColor: AppColors.darkCard,
  );
}
