import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/aruco_detection_result.dart';
import '../../domain/models/marker_pose.dart';
import '../../domain/services/aruco_pose_service.dart';
import 'calibration_provider.dart';
import '../../domain/services/marker_registry.dart';
import '../../../settings/presentation/providers/global_settings_provider.dart';

class ArucoVisionState {
  final List<ArucoDetectionResult> allDetections;
  final ArucoDetectionResult? detection; // Active tracking target
  final MarkerPose? pose; // Active target pose
  final double fps;
  final bool isProcessing;
  final String status;
  
  // Debug diagnostics
  final int frameWidth;
  final int frameHeight;
  final int rowStride;
  final String debugIds;
  final String debugError;
  final DateTime timestamp;

  ArucoVisionState({
    this.allDetections = const [],
    this.detection,
    this.pose,
    this.fps = 0.0,
    this.isProcessing = false,
    this.status = 'Starting...',
    this.frameWidth = 0,
    this.frameHeight = 0,
    this.rowStride = 0,
    this.debugIds = '[]',
    this.debugError = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  ArucoVisionState copyWith({
    List<ArucoDetectionResult>? allDetections,
    ArucoDetectionResult? detection,
    MarkerPose? pose,
    double? fps,
    bool? isProcessing,
    String? status,
    int? frameWidth,
    int? frameHeight,
    int? rowStride,
    String? debugIds,
    String? debugError,
    bool clearDetection = false,
  }) {
    return ArucoVisionState(
      allDetections: clearDetection ? [] : (allDetections ?? this.allDetections),
      detection: clearDetection ? null : (detection ?? this.detection),
      pose: clearDetection ? null : (pose ?? this.pose),
      fps: fps ?? this.fps,
      isProcessing: isProcessing ?? this.isProcessing,
      status: status ?? this.status,
      frameWidth: frameWidth ?? this.frameWidth,
      frameHeight: frameHeight ?? this.frameHeight,
      rowStride: rowStride ?? this.rowStride,
      debugIds: debugIds ?? this.debugIds,
      debugError: debugError ?? this.debugError,
    );
  }
}

final arucoVisionProvider =
    StateNotifierProvider<ArucoVisionNotifier, ArucoVisionState>((ref) {
  return ArucoVisionNotifier(ref);
});

class ArucoVisionNotifier extends StateNotifier<ArucoVisionState> {
  final Ref _ref;
  DateTime _lastFrameTime = DateTime.now();
  int _frameCount = 0;
  double _currentFps = 0.0;

  ArucoVisionNotifier(this._ref) : super(ArucoVisionState());

  void setStatus(String status) {
    if (mounted) state = state.copyWith(status: status);
  }

  void processFrame({
    required Uint8List yPlaneBytes,
    required int width,
    required int height,
    required int rowStride,
  }) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    final now = DateTime.now();
    _frameCount++;
    final elapsedMs = now.difference(_lastFrameTime).inMilliseconds;
    if (elapsedMs >= 1000) {
      _currentFps = (_frameCount / elapsedMs) * 1000.0;
      _frameCount = 0;
      _lastFrameTime = now;
    }

    final calibration = _ref.read(calibrationProvider);
    final globalSettings = _ref.read(globalSettingsProvider);

    final request = ArucoPoseRequest(
      imageBytes: yPlaneBytes,
      width: width,
      height: height,
      rowStride: rowStride,
      // targetMarkerId defaults to -1 (accept any marker)
      defaultMarkerSizeMeters: globalSettings.defaultMarkerSizeMeters,
      knownMarkerSizes: MarkerRegistry.knownMarkerSizes,
      calibration: calibration,
    );

    try {
      final response = await ArucoPoseService.detectAndEstimatePose(request);
      
      if (mounted) {
        // Enrich semantic names on the main thread
        final enrichedDetections = response.allDetections.map((d) {
          final config = MarkerRegistry.getConfig(d.markerId);
          return ArucoDetectionResult(
            markerId: d.markerId,
            corners: d.corners,
            center: d.center,
            pixelWidth: d.pixelWidth,
            pixelHeight: d.pixelHeight,
            rotationDeg: d.rotationDeg,
            confidence: d.confidence,
            semanticName: config.label,
            timestamp: d.timestamp,
          );
        }).toList();

        ArucoDetectionResult? enrichedActive;
        if (response.activeDetection != null) {
          final config = MarkerRegistry.getConfig(response.activeDetection!.markerId);
          enrichedActive = ArucoDetectionResult(
            markerId: response.activeDetection!.markerId,
            corners: response.activeDetection!.corners,
            center: response.activeDetection!.center,
            pixelWidth: response.activeDetection!.pixelWidth,
            pixelHeight: response.activeDetection!.pixelHeight,
            rotationDeg: response.activeDetection!.rotationDeg,
            confidence: response.activeDetection!.confidence,
            semanticName: config.label,
            timestamp: response.activeDetection!.timestamp,
          );
        }

        state = state.copyWith(
          allDetections: enrichedDetections,
          detection: enrichedActive,
          pose: response.activePose,
          fps: _currentFps,
          isProcessing: false,
          clearDetection: response.activeDetection == null,
          frameWidth: width,
          frameHeight: height,
          rowStride: rowStride,
          debugIds: enrichedDetections.isEmpty 
              ? '[]' 
              : '[${enrichedDetections.map((d) => d.markerId).join(', ')}]',
          debugError: '',
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isProcessing: false,
          clearDetection: true,
          status: 'Error: $e',
          debugError: e.toString(),
        );
      }
    }
  }
}
