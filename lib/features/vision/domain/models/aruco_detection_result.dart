import 'dart:math' as math;

class ArucoDetectionResult {
  final int markerId;
  final List<math.Point<double>> corners;
  final math.Point<double> center;
  final double pixelWidth;
  final double pixelHeight;
  final double rotationDeg;
  final double confidence; // 0.0 to 1.0 based on temporal stability
  final String semanticName;
  final DateTime timestamp;

  ArucoDetectionResult({
    required this.markerId,
    required this.corners,
    required this.center,
    required this.pixelWidth,
    required this.pixelHeight,
    required this.rotationDeg,
    required this.confidence,
    required this.semanticName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isValid => corners.length == 4;
}
