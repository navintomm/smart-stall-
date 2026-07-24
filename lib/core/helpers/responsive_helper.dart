import 'package:flutter/material.dart';

/// Purpose: Provides responsive breakpoints and helpers.
/// Usage: Use ResponsiveHelper.isMobile(context) to check screen size.
class ResponsiveHelper {
  static const double mobileMaxSize = 600;
  static const double tabletMaxSize = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxSize;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxSize &&
      MediaQuery.of(context).size.width < tabletMaxSize;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMaxSize;
}
