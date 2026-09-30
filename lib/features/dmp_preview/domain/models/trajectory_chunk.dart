import 'dmp_trajectory_sample.dart';

/// A single chunk of a DMP trajectory prepared for BLE streaming.
class TrajectoryChunk {
  final int chunkIndex;
  final int totalChunks;
  final List<DmpTrajectorySample> samples;

  const TrajectoryChunk({
    required this.chunkIndex,
    required this.totalChunks,
    required this.samples,
  });

  /// Serializes the chunk's samples to the exact JSON list format expected by ESP32.
  /// Format: `[ [time_ms, servo1Angle, servo2Angle], ... ]`
  List<dynamic> toJsonPayload() {
    return samples.map((s) => [
      (s.timeSeconds * 1000).round(),
      double.parse(s.servo1Angle.toStringAsFixed(1)), // Keep 1 decimal for compactness
      double.parse(s.servo2Angle.toStringAsFixed(1)),
    ]).toList();
  }
}
