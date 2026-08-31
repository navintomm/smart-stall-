import 'dart:math';
import 'package:camera/camera.dart';
import '../models/dirt_detection_model.dart';
import '../models/dirt_detection_result.dart';
import '../models/dirt_severity.dart';

/// DEVELOPMENT / MOCK MODEL
/// This class simulates AI dirt detection for Phase 21 integration.
/// IT DOES NOT PERFORM REAL INFERENCE.
class MockDirtDetectionModel implements DirtDetectionModel {
  bool _isInitialized = false;
  final Random _random = Random();

  @override
  Future<void> initialize() async {
    // Simulate model loading delay
    await Future.delayed(const Duration(milliseconds: 1500));
    _isInitialized = true;
  }

  @override
  Future<DirtDetectionResult> detect(CameraImage frame) async {
    if (!_isInitialized) {
      throw Exception('MockDirtDetectionModel is not initialized.');
    }

    // Simulate inference time
    await Future.delayed(const Duration(milliseconds: 85));

    // For development, we generate plausible random values.
    // In Simulation mode, these could be forced to specific values.
    final severityIndex = _random.nextInt(DirtSeverity.values.length);
    final severity = DirtSeverity.values[severityIndex];
    
    // Confidence is generally higher for clean or severe, lower for ambiguous states
    double confidence = 0.70 + (_random.nextDouble() * 0.25); 

    // Affected area correlates roughly with severity
    double affectedArea = 0.0;
    if (severity != DirtSeverity.clean) {
      affectedArea = 0.10 + (_random.nextDouble() * 0.60); // 10% to 70%
    }

    return DirtDetectionResult(
      detected: severity != DirtSeverity.clean,
      confidence: confidence,
      severity: severity,
      affectedArea: affectedArea,
      timestamp: DateTime.now(),
      modelVersion: 'MOCK-v0.1-DEV',
      isSimulation: true,
    );
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }
}
