import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/vision_constants.dart';
import '../../domain/models/aruco_detection_result.dart';
import '../../domain/models/marker_pose.dart';
import '../../domain/services/aruco_pose_service.dart';
import 'calibration_provider.dart';

class ArucoVisionState {
  final ArucoDetectionResult? detection;
  final MarkerPose? pose;
  final double fps;
  final bool isProcessing;
  final String status;
  
  // Debug diagnostics
  final int frameWidth;
  final int frameHeight;
  final int rowStride;
  final String debugIds;
  final String debugError;

  ArucoVisionState({
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
  });

  ArucoVisionState copyWith({
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

    final request = ArucoPoseRequest(
      imageBytes: yPlaneBytes,
      width: width,
      height: height,
      rowStride: rowStride,
      // targetMarkerId defaults to -1 (accept any marker)
      markerSizeMeters: VisionConstants.markerSizeMeters,
      calibration: calibration,
    );

    try {
      final response = await ArucoPoseService.detectAndEstimatePose(request);
      
      if (mounted) {
        state = state.copyWith(
          detection: response.detection,
          pose: response.pose,
          fps: _currentFps,
          isProcessing: false,
          clearDetection: response.detection == null,
          frameWidth: width,
          frameHeight: height,
          rowStride: rowStride,
          debugIds: response.detection != null ? '[${response.detection!.markerId}]' : '[]',
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
