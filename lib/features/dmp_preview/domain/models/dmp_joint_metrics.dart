/// Per-joint numerical metrics produced by the DMP pipeline for one servo.
class DmpJointMetrics {
  final String jointName;

  /// Mean Absolute Error between original and generated trajectory (degrees).
  final double mae;

  /// Root Mean Squared Error (degrees).
  final double rmse;

  /// Largest single-sample absolute error (degrees).
  final double maxError;

  /// Sum of squared jerk values of the ORIGINAL demonstrated trajectory.
  /// A raw signal-quality measure: lower is smoother.
  /// This is the Savitzky-Golay 3rd-derivative sum — not a pass/fail criterion.
  final double smoothnessOriginal;

  /// Sum of squared jerk values of the DMP-GENERATED trajectory.
  final double smoothnessGenerated;

  const DmpJointMetrics({
    required this.jointName,
    required this.mae,
    required this.rmse,
    required this.maxError,
    required this.smoothnessOriginal,
    required this.smoothnessGenerated,
  });
}
