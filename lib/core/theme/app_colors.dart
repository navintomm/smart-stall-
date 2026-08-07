import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF22C55E); // Soft Mint Green
  static const Color secondary = Color(0xFF15803D); // Forest Green
  static const Color accent = Color(0xFFC8F1D6); // Light Mint
  
  // Base Colors
  static const Color backgroundLight = Color(0xFFF8FAFC); // Warm White
  static const Color cardGlass = Color(0xFFFFFFFF); // Pure White
  
  // Text Colors
  static const Color text = Color(0xFF111827); // Near Black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light Gray
  
  // Semantic Colors
  static const Color successGreen = Color(0xFF22C55E); // Mint Green
  static const Color warningOrange = Color(0xFFF59E0B); // Soft Orange
  static const Color dangerRed = Color(0xFFEF4444); // Soft Red
  static const Color informationCyan = Color(0xFF06B6D4);
  
  // UI Elements
  static const Color borderLight = Color(0xFFE5E7EB); // Ultra Light Gray
  
  // Gradients (Kept for compatibility, but updated to very subtle if needed, though we avoid heavy gradients)
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );
}

