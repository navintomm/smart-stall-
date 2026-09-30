/// A single time-indexed sample of the DMP-generated (or original) trajectory.
class DmpTrajectorySample {
  final double timeSeconds;
  final double servo1Angle; // degrees
  final double servo2Angle; // degrees

  const DmpTrajectorySample({
    required this.timeSeconds,
    required this.servo1Angle,
    required this.servo2Angle,
  });
}
