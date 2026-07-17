import 'package:flutter/material.dart';

class AppColors {
  // Deep Maroon & Gold Palette (Classy/Premium)
  static const Color primary = Color(0xFF6B0F2B);
  static const Color primaryLight = Color(0xFF8E1B3E);
  static const Color primaryDark = Color(0xFF4A0A1E);
  
  static const Color accentGold = Color(0xFFD4A017);
  static const Color accentGoldLight = Color(0xFFFFD700);
  
  // Light Theme
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color sidebarBackgroundLight = Color(0xFF1A1A1A);
  
  // Dark Theme
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color sidebarBackgroundDark = Color(0xFF0A0A0A);
  
  // Feedback
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);
  
  // Light Theme Text
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color textOnPrimaryLight = Colors.white;
  static const Color textOnSurfaceLight = Color(0xFF212529);
  
  // Dark Theme Text
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondaryDark = Color(0xFFADB5BD);
  static const Color textOnPrimaryDark = Colors.white;
  static const Color textOnSurfaceDark = Color(0xFFF8F9FA);
  
  // Light Theme Borders/Dividers
  static const Color borderLight = Color(0xFFDEE2E6);
  static const Color dividerLight = Color(0xFFE9ECEF);
  
  // Dark Theme Borders/Dividers
  static const Color borderDark = Color(0xFF343A40);
  static const Color dividerDark = Color(0xFF495057);

  // Status Tiers
  static const Color tierPremium = Color(0xFFD4A017);
  static const Color tierVerified = Color(0xFF007BFF);
  static const Color tierFree = Color(0xFF6C757D);

  // Backward compatibility
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color sidebarBackground = sidebarBackgroundLight;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryLight;
  static const Color textOnPrimary = textOnPrimaryLight;
  static const Color textOnSurface = textOnSurfaceLight;
  static const Color border = borderLight;
  static const Color divider = dividerLight;
}
