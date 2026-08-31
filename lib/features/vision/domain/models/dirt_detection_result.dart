import 'dirt_severity.dart';

class DirtDetectionResult {
  final bool detected;
  final double confidence;
  final DirtSeverity severity;
  final double affectedArea;
  final DateTime timestamp;
  final String modelVersion;
  final bool isSimulation;

  const DirtDetectionResult({
    required this.detected,
    required this.confidence,
    required this.severity,
    required this.affectedArea,
    required this.timestamp,
    required this.modelVersion,
    this.isSimulation = false,
  });

  factory DirtDetectionResult.empty() {
    return DirtDetectionResult(
      detected: false,
      confidence: 0.0,
      severity: DirtSeverity.clean,
      affectedArea: 0.0,
      timestamp: DateTime.now(),
      modelVersion: 'Unknown',
    );
  }
}
