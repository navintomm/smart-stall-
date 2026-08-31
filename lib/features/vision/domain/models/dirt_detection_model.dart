import 'package:camera/camera.dart';
import 'dirt_detection_result.dart';

/// Abstract interface for the AI Dirt Detection Model.
/// This allows the mock implementation to be easily replaced by a real TFLite 
/// or ONNX model in the future without changing the service layer.
abstract class DirtDetectionModel {
  /// Initializes the model, allocating resources.
  Future<void> initialize();

  /// Processes a single camera frame and returns the detection result.
  Future<DirtDetectionResult> detect(CameraImage frame);

  /// Releases resources when the model is no longer needed.
  Future<void> dispose();
}
