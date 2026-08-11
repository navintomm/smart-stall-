import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/vision_constants.dart';
import '../../domain/models/alignment_result.dart';
import 'aruco_vision_provider.dart';

final alignmentProvider = Provider<AlignmentResult>((ref) {
  final visionState = ref.watch(arucoVisionProvider);

  if (visionState.detection == null) {
    return AlignmentResult.empty(AlignmentStatus.markerLost);
  }

  final pose = visionState.pose;
  if (pose == null) {
    // We have a detection but no pose (maybe solvePnP failed)
    return AlignmentResult.empty(AlignmentStatus.scanning);
  }

  // Calculate errors
  final horizontalError = pose.x.abs();
  final verticalError = pose.y.abs();
  final distanceError = (pose.distance - VisionConstants.targetDistanceMeters).abs();
  final yawError = pose.yaw.abs();

  // Normalize scores (0.0 means outside tolerance, 1.0 means perfect 0 error)
  double hScore = 1.0 - (horizontalError / VisionConstants.maxHorizontalErrorMeters).clamp(0.0, 1.0);
  double vScore = 1.0 - (verticalError / VisionConstants.maxVerticalErrorMeters).clamp(0.0, 1.0);
  double dScore = 1.0 - (distanceError / VisionConstants.maxDistanceErrorMeters).clamp(0.0, 1.0);
  double yawScore = 1.0 - (yawError / VisionConstants.maxYawErrorDegrees).clamp(0.0, 1.0);

  // Overall score is weighted average
  double totalScore = (hScore * 0.3) + (vScore * 0.3) + (dScore * 0.2) + (yawScore * 0.2);

  AlignmentStatus status = AlignmentStatus.aligning;
  if (totalScore >= VisionConstants.alignmentScoreThreshold) {
    status = AlignmentStatus.ready;
  }

  return AlignmentResult(
    horizontalErrorM: pose.x,
    verticalErrorM: pose.y,
    distanceErrorM: (pose.distance - VisionConstants.targetDistanceMeters),
    yawErrorDeg: pose.yaw,
    score: totalScore,
    status: status,
  );
});

// A provider that applies an Exponential Moving Average (EMA) to smooth the alignment score
final smoothedAlignmentProvider = StateNotifierProvider<SmoothedAlignmentNotifier, AlignmentResult>((ref) {
  final currentRaw = ref.watch(alignmentProvider);
  return SmoothedAlignmentNotifier(currentRaw);
});

class SmoothedAlignmentNotifier extends StateNotifier<AlignmentResult> {
  final double alpha = 0.3; // Smoothing factor (0 < alpha <= 1)

  SmoothedAlignmentNotifier(super.initial);

  @override
  set state(AlignmentResult newState) {
    if (newState.status == AlignmentStatus.markerLost || 
        newState.status == AlignmentStatus.error ||
        newState.status == AlignmentStatus.scanning) {
      super.state = newState;
      return;
    }

    final smoothedScore = (alpha * newState.score) + ((1 - alpha) * super.state.score);
    
    // Re-evaluate status based on smoothed score
    AlignmentStatus status = AlignmentStatus.aligning;
    if (smoothedScore >= VisionConstants.alignmentScoreThreshold) {
      status = AlignmentStatus.ready;
    }

    super.state = AlignmentResult(
      horizontalErrorM: (alpha * newState.horizontalErrorM) + ((1 - alpha) * super.state.horizontalErrorM),
      verticalErrorM: (alpha * newState.verticalErrorM) + ((1 - alpha) * super.state.verticalErrorM),
      distanceErrorM: (alpha * newState.distanceErrorM) + ((1 - alpha) * super.state.distanceErrorM),
      yawErrorDeg: (alpha * newState.yawErrorDeg) + ((1 - alpha) * super.state.yawErrorDeg),
      score: smoothedScore,
      status: status,
    );
  }
}
