import 'package:flutter/material.dart';

class AppShadows {
  static final List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> glowShadow = [
    BoxShadow(
      color: const Color(0xFF6366F1).withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];
}
