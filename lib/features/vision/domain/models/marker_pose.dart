import 'dart:math';

class MarkerPose {
  final double x; // meters
  final double y; // meters
  final double z; // meters
  final double roll; // degrees
  final double pitch; // degrees
  final double yaw; // degrees

  MarkerPose({
    required this.x,
    required this.y,
    required this.z,
    required this.roll,
    required this.pitch,
    required this.yaw,
  });

  /// Euclidean distance to the marker in meters.
  double get distance => sqrt(x * x + y * y + z * z);
}
