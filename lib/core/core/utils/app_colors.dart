import 'dart:ui';

class AppColors {
  // Backgrounds - Warm Beige & Cream Palette
  static const Color backgroundPrimary   = Color(0xFFF9F6F2); // Warm cream/off-white
  static const Color backgroundSecondary = Color(0xFFEFE9E1); // Soft sand beige
  static const Color cardBackground      = Color(0xFFFFFFFF); // Pure white for cards

  // Brand Colors - Rich Browns & Elegant Beiges
  // We keep 'primaryBlue' name so existing code doesn't break, but change value to Brown
  static const Color primaryBlue      = Color(0xFF6F4E37); // Rich Coffee Brown
  static const Color primaryBlueLight = Color(0xFFD7CCC8); // Soft Latte
  static const Color primaryBlueSoft  = Color(0xFFEFEBE9); // Very light linen
  static const Color primaryGold      = Color(0xFFC5A380); // Classic Beige Gold
  static const Color primaryGoldLight = Color(0xFFF1EBE1); // Pale Parchment

  // Text - Deep Espresso & Cocoa Tones
  static const Color textPrimary      = Color(0xFF3E2723); // Deepest Espresso
  static const Color textSecondary    = Color(0xFF5D4037); // Medium Cocoa
  static const Color textTertiary     = Color(0xFF8D6E63); // Muted Brown
  static const Color textPlaceholder  = Color(0xFFBCAAA4); // Muted Tan hint text

  // Borders & Accents
  static const Color borderSoft   = Color(0xFFE0D7D0);
  static const Color borderMedium = Color(0xFFCBBFBB);
  static const Color shadowColor  = Color(0x1A4E342E); // Soft brown-tinted shadow

  // Status Colors (Warm variants)
  static const Color success      = Color(0xFF689F38); // Olive Green
  static const Color successLight = Color(0xFFF1F8E9);
  static const Color warning      = Color(0xFFEF6C00); // Deep Amber
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error        = Color(0xFFB71C1C); // Deep Brick Red
  static const Color errorLight   = Color(0xFFFFEBEE);

  // System Colors
  static const Color whiteColor        = Color(0xFFFFFFFF);
  static const Color blackColor        = Color(0xFF1B120F); // Warm brownish-black
  static const Color transparentColor  = Color(0x00000000);

  // Dark Mode (Rich Dark Browns)
  static const Color darkBackground = Color(0xFF211A18);
  static const Color darkCard       = Color(0xFF2D2421);
  static const Color darkBorder     = Color(0xFF3E312D);

  // Legacy colors (Directly used in LoginScreen)
  static const Color primaryColor         = primaryBlue;     // Now Brown
  static const Color grayColor            = textSecondary;   // Now Cocoa Grey
  static const Color placeholderTextColor = textPlaceholder; // Now Muted Tan
  static const Color redColor             = error;           // Now Brick Red
  static const Color lightGreyColor        = backgroundSecondary;
  static const Color mutedForeground       = textTertiary;

  // Custom palette extensions
  static const Color accentGold = primaryGold;
  static const Color pinkColor  = Color(0xFFD81B60);
}
