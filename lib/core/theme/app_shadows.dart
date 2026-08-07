import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x08000000), // 3% black for ambient shadow
      offset: Offset(0, 12),
      blurRadius: 32,
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x05000000), // 2% black for sharper base
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> glowingGreen = [
    BoxShadow(
      color: Color(0x3322C55E), // Mint glow
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
  
  static const List<BoxShadow> glowingRed = [
    BoxShadow(
      color: Color(0x33EF4444), // Red glow
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> glowShadow = glowingGreen;
  static const List<BoxShadow> glassShadow = cardShadow;
}

