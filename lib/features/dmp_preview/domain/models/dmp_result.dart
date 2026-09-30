import 'dmp_trajectory_sample.dart';
import 'dmp_joint_metrics.dart';

/// The complete result produced by the DMP pipeline for a single recording.
///
/// This is a pure domain model — it does NOT connect to BLE, ESP32 or any
/// physical actuator.  It exists solely for in-app preview and validation.
class DmpResult {
  /// Unique identifier matching the source [Routine.id].
  final String routineId;

  /// Human-readable name carried from the source routine.
  final String routineName;

  /// Total playback duration in seconds.
  final double durationSeconds;

  /// The original human-demonstrated trajectory (from RoutineFrames).
  final List<DmpTrajectorySample> originalSamples;

  /// The DMP-generated trajectory.
  final List<DmpTrajectorySample> generatedSamples;

  /// Per-joint error metrics.
  final DmpJointMetrics servo1Metrics;
  final DmpJointMetrics servo2Metrics;

  /// Whether start position is preserved (|original[0] - generated[0]| <= 0.1°).
  final bool startPositionPreserved;

  /// Whether goal position is preserved (|original[-1] - generated[-1]| <= 1.5°).
  final bool goalPositionPreserved;

  /// True if the generated trajectory contains no NaN values.
  final bool noNanValues;

  /// True if the generated trajectory contains no infinite values.
  final bool noInfiniteValues;

  /// Whether this result has been approved for future (offline) use.
  /// Approval DOES NOT execute the physical robot.
  final bool isApproved;

  const DmpResult({
    required this.routineId,
    required this.routineName,
    required this.durationSeconds,
    required this.originalSamples,
    required this.generatedSamples,
    required this.servo1Metrics,
    required this.servo2Metrics,
    required this.startPositionPreserved,
    required this.goalPositionPreserved,
    required this.noNanValues,
    required this.noInfiniteValues,
    this.isApproved = false,
  });

  /// Total number of samples (should match original count).
  int get sampleCount => generatedSamples.length;

  /// Whether enough samples exist (minimum 10) to constitute a valid trajectory.
  bool get hasSufficientSamples => generatedSamples.length >= 10;

  DmpResult copyWith({bool? isApproved}) {
    return DmpResult(
      routineId: routineId,
      routineName: routineName,
      durationSeconds: durationSeconds,
      originalSamples: originalSamples,
      generatedSamples: generatedSamples,
      servo1Metrics: servo1Metrics,
      servo2Metrics: servo2Metrics,
      startPositionPreserved: startPositionPreserved,
      goalPositionPreserved: goalPositionPreserved,
      noNanValues: noNanValues,
      noInfiniteValues: noInfiniteValues,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
