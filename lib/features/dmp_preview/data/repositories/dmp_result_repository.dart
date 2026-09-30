import '../../domain/models/dmp_joint_metrics.dart';
import '../../domain/models/dmp_result.dart';
import '../../domain/models/dmp_trajectory_sample.dart';
import '../../../settings/domain/models/routine.dart';


/// Converts a [Routine] (recorded human demonstration) + a pre-computed
/// DMP result into a [DmpResult] domain model.
///
/// In this checkpoint the DMP computation happens OFFLINE in Python.
/// This repository layer reads from locally available data structures.
/// A future integration point can replace [fromRoutineWithDmpOutput] with
/// a service that invokes the Python subprocess or reads a generated file.
class DmpResultRepository {
  /// Build a [DmpResult] from a [Routine] (original trajectory) plus
  /// externally computed DMP samples and metrics.
  ///
  /// [originalRoutine]    – the recorded human demonstration.
  /// [generatedSamples]   – DMP-generated trajectory samples.
  /// [servo1Metrics]      – per-joint error metrics for Servo 1.
  /// [servo2Metrics]      – per-joint error metrics for Servo 2.
  /// [startPreserved]     – whether start position is within threshold.
  /// [goalPreserved]      – whether goal position is within threshold.
  static DmpResult fromRoutineWithDmpOutput({
    required Routine originalRoutine,
    required List<DmpTrajectorySample> generatedSamples,
    required DmpJointMetrics servo1Metrics,
    required DmpJointMetrics servo2Metrics,
    required bool startPreserved,
    required bool goalPreserved,
  }) {
    // Convert routine frames to trajectory samples
    final originalSamples = originalRoutine.frames
        .map((f) => DmpTrajectorySample(
              timeSeconds: f.timestampMs / 1000.0,
              servo1Angle: f.servoAngles['s1'] ?? 0.0,
              servo2Angle: f.servoAngles['s2'] ?? 0.0,
            ))
        .toList();

    final durationSeconds = originalRoutine.frames.isNotEmpty
        ? originalRoutine.frames.last.timestampMs / 1000.0
        : 0.0;

    // Verify no NaN/Inf in generated samples
    final hasNaN = generatedSamples.any(
      (s) => s.servo1Angle.isNaN || s.servo2Angle.isNaN,
    );
    final hasInf = generatedSamples.any(
      (s) => s.servo1Angle.isInfinite || s.servo2Angle.isInfinite,
    );

    return DmpResult(
      routineId: originalRoutine.id,
      routineName: originalRoutine.name,
      durationSeconds: durationSeconds,
      originalSamples: originalSamples,
      generatedSamples: generatedSamples,
      servo1Metrics: servo1Metrics,
      servo2Metrics: servo2Metrics,
      startPositionPreserved: startPreserved,
      goalPositionPreserved: goalPreserved,
      noNanValues: !hasNaN,
      noInfiniteValues: !hasInf,
    );
  }
}
