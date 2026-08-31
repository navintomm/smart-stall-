import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dirt_detection_model.dart';
import '../models/dirt_detection_result.dart';
import 'mock_dirt_detection_model.dart';

final dirtDetectionServiceProvider = Provider<DirtDetectionService>((ref) {
  final service = DirtDetectionService(MockDirtDetectionModel());
  // Initialize lazily or eagerly depending on requirements.
  return service;
});

class DirtDetectionService {
  final DirtDetectionModel _model;
  bool _isProcessing = false;
  bool _isInitialized = false;

  DirtDetectionService(this._model);

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _model.initialize();
    _isInitialized = true;
  }

  /// Consumes a frame from the shared camera stream and processes it.
  /// Throttles processing to avoid queueing up too many frames.
  Future<DirtDetectionResult?> processFrame(CameraImage frame) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isProcessing) {
      // Drop frame if we are currently busy
      return null;
    }

    _isProcessing = true;
    try {
      final result = await _model.detect(frame);
      return result;
    } catch (e) {
      // Handle or log error
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> dispose() async {
    await _model.dispose();
    _isInitialized = false;
  }
}
