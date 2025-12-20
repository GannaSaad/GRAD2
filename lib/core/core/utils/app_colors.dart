import 'dart:ui';

class AppColors {
  // Dentix Primary Colors - Warm beige/sand theme
  static const Color backgroundPrimary = Color(0xFFF5F2ED); // Warm beige/sand background
  static const Color backgroundSecondary = Color(0xFFF9F7F4); // Lighter sand variant
  static const Color cardBackground = Color(0xFFFFFFFB); // Soft off-white for cards
  
  // Primary Blue System
  static const Color primaryBlue = Color(0xFF2B5CE6); // Main blue for actions
  static const Color primaryBlueLight = Color(0xFF4A7BF7); // Lighter blue for hover/active
  static const Color primaryBlueSoft = Color(0xFFE8F0FF); // Very light blue for backgrounds
  
  // Text Colors - Healthcare-grade readability
  static const Color textPrimary = Color(0xFF2C2C2E); // Dark grey for primary text
  static const Color textSecondary = Color(0xFF6D6D70); // Medium grey for secondary text
  static const Color textTertiary = Color(0xFF8E8E93); // Light grey for tertiary text
  static const Color textPlaceholder = Color(0xFFAEAEB2); // Placeholder text
  
  // Neutral System
  static const Color borderSoft = Color(0xFFE5E5E7); // Soft borders
  static const Color borderMedium = Color(0xFFD1D1D6); // Medium borders
  static const Color shadowColor = Color(0x0A000000); // Subtle shadow (4% black)
  
  // Status Colors - Medical-friendly soft tones
  static const Color success = Color(0xFF30D158); // Soft green
  static const Color successLight = Color(0xFFE8F5E8); // Light green background
  static const Color warning = Color(0xFFFF9F0A); // Soft orange
  static const Color warningLight = Color(0xFFFFF4E6); // Light orange background
  static const Color error = Color(0xFFFF3B30); // Soft red
  static const Color errorLight = Color(0xFFFFEBEA); // Light red background
  
  // System Colors (maintaining compatibility)
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color transparentColor = Color(0x00000000);
  
  // Dark Mode Colors (medical-friendly)
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkCard = Color(0xFF2C2C2E);
  static const Color darkBorder = Color(0xFF38383A);
  
  // Legacy colors (for backward compatibility)
  static const Color primaryColor = primaryBlue;
  static const Color grayColor = textSecondary;
  static const Color placeholderTextColor = textPlaceholder;
  static const Color redColor = error;
  static const Color lightGreyColor = backgroundSecondary;
  static const Color mutedForeground = textTertiary;
  static const Color pinkColor = Color(0xFFFF2D55);
  static const Color orangeColor = warning;
  static const Color greenColor = success;
}