import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x06000000), // 3% black 
      offset: Offset(0, 20),
      blurRadius: 60,
      spreadRadius: 10,
    ),
    BoxShadow(
      color: Color(0x03000000), // 1% black for close base
      offset: Offset(0, 4),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> glowingGreen = [
    BoxShadow(
      color: Color(0x3367E279), // New Mint glow
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

