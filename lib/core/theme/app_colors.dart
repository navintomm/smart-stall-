import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF22C55E); // Mint Green
  static const Color secondary = Color(0xFF15803D); // Forest Green
  static const Color accent = Color(0xFF86EFAC); // Light Mint
  
  // Base Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Warm White
  static const Color cardGlass = Color(0xFFFFFFFF); // Pure White
  
  // Text Colors
  static const Color text = Color(0xFF1F2937); // Dark Charcoal
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light Gray
  
  // Semantic Colors
  static const Color successGreen = Color(0xFF22C55E); 
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color informationCyan = Color(0xFF06B6D4);
  
  // UI Elements
  static const Color borderLight = Color(0xFFE5E7EB); // Soft Grey Border
  
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

