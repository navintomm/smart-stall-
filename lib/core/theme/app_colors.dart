import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF67E279); // Pastel/Neon Mint Green
  static const Color secondary = Color(0xFF111111); // Stark Black for buttons
  static const Color accent = Color(0xFFC8F1D6); // Light Mint
  
  // Base Colors
  static const Color backgroundLight = Color(0xFFF2F6F2); // Soft Cream/Mint
  static const Color cardGlass = Color(0xFFFFFFFF); // Pure White
  
  // Text Colors
  static const Color text = Color(0xFF111111); // Near Black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light Gray
  
  // Semantic Colors
  static const Color successGreen = Color(0xFF67E279); 
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color informationCyan = Color(0xFF06B6D4);
  
  // UI Elements
  static const Color borderLight = Color(0xFFF3F4F6); // Ultra Light Gray
  
  // Gradients (Kept for compatibility)
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );
}

