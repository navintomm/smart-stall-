import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF8B5CF6);
  
  // Base Colors
  static const Color text = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  
  static const Color backgroundLight = Color(0xFFF1F5F9); // Very light slate
  static const Color cardGlass = Color(0xCCFFFFFF); // 80% white for glass
  
  // Semantic / Robot Colors
  static const Color robotBlue = Color(0xFF3B82F6);
  static const Color robotPurple = Color(0xFF8B5CF6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color informationCyan = Color(0xFF06B6D4);
  
  // Gradients
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xE6FFFFFF),
      Color(0x99FFFFFF),
    ],
  );
}
