import 'package:flutter/material.dart';

// Design system colors for BunaLens
// Coffee-inspired palette with warm browns and cream tones
class AppColors {
  // BRAND COLORS - Coffee Palette
  
  // Primary coffee brown - main brand color
  static const Color coffeeBrown = Color(0xFF6F4E37);
  
  // Dark roast - deeper brown for emphasis
  static const Color darkRoast = Color(0xFF4A3426);
  
  // Medium roast - lighter brown variant
  static const Color mediumRoast = Color(0xFF8B6F47);
  
  // Light roast - warm tan
  static const Color lightRoast = Color(0xFFA67B5B);
  
  // Cream - light accent color
  static const Color cream = Color(0xFFFFF8E7);
  
  // Beige - neutral background
  static const Color beige = Color(0xFFF5F1E8);
  
  // Espresso - almost black for text
  static const Color espresso = Color(0xFF2B1810);

  
  // SEMANTIC COLORS
  
  // Success - for premium/high quality beans
  static const Color success = Color(0xFF4CAF50);
  
  // Warning - for defects or low confidence
  static const Color warning = Color(0xFFFFA726);
  
  // Error - for errors and critical issues
  static const Color error = Color(0xFFE53935);
  
  // Info - for informational messages
  static const Color info = Color(0xFF42A5F5);

  // COFFEE CLASS COLORS
  
  // Premium grade - rich golden brown
  static const Color premium = Color(0xFFD4AF37);
  
  // Longberry grade - warm medium brown
  static const Color longberry = Color(0xFF8B6F47);
  
  // Peaberry grade - light brown
  static const Color peaberry = Color(0xFFC4A57B);
  
  // Defect - red-brown for defective beans
  static const Color defect = Color(0xFFA0522D);
  
  // Out of Distribution - gray for unknown
  static const Color ood = Color(0xFF9E9E9E);

  // NEUTRAL COLORS
  
  // White
  static const Color white = Color(0xFFFFFFFF);
  
  // Light gray
  static const Color lightGray = Color(0xFFF5F5F5);
  
  // Gray
  static const Color gray = Color(0xFF9E9E9E);
  
  // Dark gray
  static const Color darkGray = Color(0xFF616161);
  
  // Black
  static const Color black = Color(0xFF000000);

  // GRADIENTS
  
  // Coffee gradient - dark to light roast
  static const LinearGradient coffeeGradient = LinearGradient(
    colors: [darkRoast, mediumRoast, lightRoast],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Premium gradient - golden shine
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFD4AF37), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // BACKWARD-COMPAT ALIASES

  // Alias for [darkRoast] — matches old AppColors.coffeeDark
  static const Color coffeeDark = darkRoast;

  // Alias for [beige] — matches old AppColors.coffeeLight
  static const Color coffeeLight = beige;

  // Alias for [mediumRoast] — matches old AppColors.caramel
  static const Color caramel = mediumRoast;

  // Alias for [defect] — matches old AppColors.defectColor
  static const Color defectColor = defect;

  // Alias for [longberry] — matches old AppColors.longberryColor
  static const Color longberryColor = longberry;

  // Alias for [peaberry] — matches old AppColors.peaberryColor
  static const Color peaberryColor = peaberry;

  // Alias for [premium] — matches old AppColors.premiumColor
  static const Color premiumColor = premium;

  // HELPER METHODS
  
  // Get color for coffee class
  static Color getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'premium':
        return premium;
      case 'longberry':
        return longberry;
      case 'peaberry':
        return peaberry;
      case 'defect':
        return defect;
      default:
        return ood;
    }
  }
  
  // Get confidence color based on percentage
  // Low: 0-50% (warning), Medium: 50-75% (info), High: 75-100% (success)
  static Color getConfidenceColor(double confidence) {
    if (confidence < 0.5) return warning;
    if (confidence < 0.75) return info;
    return success;
  }
  
  /// Get OOD color with opacity
  static Color getOodColor([double opacity = 1.0]) {
    return ood.withOpacity(opacity);
  }
}
