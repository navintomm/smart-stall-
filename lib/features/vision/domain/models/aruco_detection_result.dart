import 'dart:math' as math;

class ArucoDetectionResult {
  final int markerId;
  final List<math.Point<double>> corners;
  final double confidence; // 0.0 to 1.0 based on temporal stability
  final DateTime timestamp;

  ArucoDetectionResult({
    required this.markerId,
    required this.corners,
    required this.confidence,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isValid => corners.length == 4;
}
