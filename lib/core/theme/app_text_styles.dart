import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Hero (36-40px, DM Serif Display, Regular)
  static TextStyle get displayLarge => GoogleFonts.dmSerifDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );

  // Screen Title / Section Title (28-30px, DM Serif Display, Regular)
  static TextStyle get displayMedium => GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
      
  // Card Title (20-22px, Inter, SemiBold)
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      );

  // Body (16px, Inter, Regular)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.text,
      );
      
  // Caption (13-14px, Inter, Regular)
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );
      
  // Small Label (12px, Inter, Medium)
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
      );
}
