class ResponsiveBreakpoints {
  static const double mobile = 480.0;
  static const double tablet = 768.0;
  static const double desktop = 1024.0;
}

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

DeviceScreenType getDeviceType(double width) {
  if (width >= ResponsiveBreakpoints.desktop) {
    return DeviceScreenType.desktop;
  }
  if (width >= ResponsiveBreakpoints.tablet) {
    return DeviceScreenType.tablet;
  }
  return DeviceScreenType.mobile;
}
