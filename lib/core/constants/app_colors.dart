import 'package:flutter/material.dart';

/// Application color constants based on the Vyāpāra Gateway design system
class AppColors {
  AppColors._();

  // Primary Colors (Deep Purple/Pink Theme)
  static const Color primary = Color(0xFF6366F1); // Deep purple/indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF8B5CF6);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink accent
  static const Color secondaryDark = Color(0xFFDB2777);
  static const Color secondaryLight = Color(0xFFF472B6);

  // Accent Colors - Simplified to 3 main colors
  static const Color accent = Color(
    0xFF36AD35,
  ); // Green accent (was accentGreen)

  // Background Colors (Figma Design)
  static const Color backgroundDark = Color(
    0xFF161616,
  ); // Exact Figma background
  static const Color surfaceDark = Color(0xFF161616); // Same as background
  static const Color cardDark = Color(0xFF161616); // Dark card background

  // Dark Theme Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white text
  static const Color textSecondary = Color(0xFFAAAAAA); // Gray from Figma
  static const Color textTertiary = Color(0xFF666666); // Darker gray
  static const Color textOnDark = Color(
    0xFF111827,
  ); // Dark text on light backgrounds

  // Light Theme Text Colors
  static const Color textPrimaryLight = Color(
    0xFF111827,
  ); // Dark text for light theme
  static const Color textSecondaryLight = Color(
    0xFF6B7280,
  ); // Gray for light theme
  static const Color textTertiaryLight = Color(
    0xFF9CA3AF,
  ); // Light gray for light theme

  // Light Theme Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA); // Light background
  static const Color surfaceLight = Color(0xFFFFFFFF); // Light surface
  static const Color cardLight = Color(0xFFFFFFFF); // Light card background

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border Colors
  static const Color borderLight = Color(0xFF374151);
  static const Color borderMedium = Color(0xFF4B5563);
  static const Color borderDark = Color(0xFF6B7280);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFEC4899),
    Color(0xFFF472B6),
  ];

  // Simplified 3-Color System
  // Primary: Purple/Indigo (0xFF6366F1)
  // Secondary: Pink (0xFFEC4899)
  // Accent: Green (0xFF36AD35)
}
