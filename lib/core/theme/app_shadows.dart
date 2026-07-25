import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000), // Very light 10% black
      offset: Offset(0, 10),
      blurRadius: 30,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black for ambient shadow
      offset: Offset(0, 4),
      blurRadius: 10,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> glowingBlue = [
    BoxShadow(
      color: Color(0x4D3B82F6), // 30% blue
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> glowingGreen = [
    BoxShadow(
      color: Color(0x4D10B981),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];
  
  static const List<BoxShadow> glowingRed = [
    BoxShadow(
      color: Color(0x4DEF4444),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> glowShadow = glowingBlue;
  static const List<BoxShadow> glassShadow = cardShadow;
}

