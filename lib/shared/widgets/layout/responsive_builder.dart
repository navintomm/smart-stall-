import 'package:flutter/material.dart';
import '../../../core/utils/responsive_breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context)? mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;
  final Widget Function(BuildContext context) builder; // Fallback or base builder

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);
        
        if (deviceType == DeviceScreenType.desktop && desktop != null) {
          return desktop!(context);
        }
        
        if (deviceType == DeviceScreenType.tablet && tablet != null) {
          return tablet!(context);
        }
        
        if (deviceType == DeviceScreenType.mobile && mobile != null) {
          return mobile!(context);
        }
        
        return builder(context);
      },
    );
  }
}
