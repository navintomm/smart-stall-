class VisionConstants {
  /// The exact physical size of the ArUco marker in metres (150mm).
  /// This must match the printed marker exactly for accurate distance/pose estimation.
  static const double markerSizeMeters = 0.150;

  /// The target ArUco marker ID that the operator workflow should align with.
  /// (Marker ID 1 represents the toilet/cleaning target).
  static const int targetMarkerId = 1;

  /// Checkerboard inner corner dimensions for camera calibration.
  static const int checkerboardColumns = 7;
  static const int checkerboardRows = 5;
  static const double checkerboardSquareSizeMeters = 0.030; // 30mm standard, adjustable

  // Alignment Tolerances
  static const double maxHorizontalErrorMeters = 0.05; // ±5cm
  static const double maxVerticalErrorMeters = 0.05; // ±5cm
  static const double maxYawErrorDegrees = 5.0; // ±5 degrees
  static const double targetDistanceMeters = 0.6; // e.g. 60cm optimal distance
  static const double maxDistanceErrorMeters = 0.2; // ±20cm from target

  static const double alignmentScoreThreshold = 0.95; // 95% alignment required to start
}
