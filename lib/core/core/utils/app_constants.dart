import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppConstants {
  // Dentix Spacing System - Mobile-first, healthcare-friendly
  
  // Base spacing unit (8dp system)
  static const double baseUnit = 8.0;
  
  // Padding Constants
  static double paddingXS = 4.w; // Extra small - 4dp
  static double paddingS = 8.w; // Small - 8dp
  static double paddingM = 16.w; // Medium - 16dp (default)
  static double paddingL = 24.w; // Large - 24dp
  static double paddingXL = 32.w; // Extra large - 32dp
  static double paddingXXL = 48.w; // Extra extra large - 48dp
  
  // Card and Container Padding
  static double cardPadding = 16.w;
  static double cardPaddingLarge = 24.w;
  static double containerPadding = 20.w;
  
  // Screen Margins
  static double screenMargin = 20.w;
  static double screenMarginSmall = 16.w;
  
  // Border Radius System - Consistent rounded corners
  static double radiusXS = 4.r; // Extra small - 4dp
  static double radiusS = 8.r; // Small - 8dp
  static double radiusM = 12.r; // Medium - 12dp (default)
  static double radiusL = 16.r; // Large - 16dp
  static double radiusXL = 20.r; // Extra large - 20dp
  static double radiusXXL = 24.r; // Extra extra large - 24dp
  static double radiusRound = 50.r; // Fully rounded
  
  // Component-specific radius
  static double buttonRadius = 12.r;
  static double cardRadius = 16.r;
  static double inputRadius = 12.r;
  static double chipRadius = 20.r;
  
  // Elevation/Shadow System
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationMax = 16.0;
  
  // Icon Sizes
  static double iconXS = 12.w;
  static double iconS = 16.w;
  static double iconM = 24.w;
  static double iconL = 32.w;
  static double iconXL = 48.w;
  
  // Button Heights
  static double buttonHeightSmall = 36.h;
  static double buttonHeightMedium = 48.h;
  static double buttonHeightLarge = 56.h;
  
  // Input Field Heights
  static double inputHeightSmall = 40.h;
  static double inputHeightMedium = 48.h;
  static double inputHeightLarge = 56.h;
  
  // Minimum tap target size (accessibility)
  static double minTapTarget = 44.w;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}