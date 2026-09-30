import '../models/dmp_trajectory_sample.dart';
import '../models/trajectory_chunk.dart';

class TrajectoryChunker {
  /// Maximum number of samples per chunk.
  /// Based on the ESP32 WifiServerHandler 2048-byte line buffer limit.
  /// A sample `[1234, 150.1, 90.5]` is ~22 bytes in JSON.
  /// 20 samples * 22 bytes = 440 bytes. Very safe limit.
  static const int maxSamplesPerChunk = 20;

  /// Splits a continuous DMP trajectory into deterministic BLE-safe chunks.
  static List<TrajectoryChunk> chunkTrajectory(List<DmpTrajectorySample> samples) {
    if (samples.isEmpty) return [];

    final chunks = <TrajectoryChunk>[];
    final totalChunks = (samples.length / maxSamplesPerChunk).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final startIndex = i * maxSamplesPerChunk;
      final endIndex = startIndex + maxSamplesPerChunk;
      
      chunks.add(
        TrajectoryChunk(
          chunkIndex: i,
          totalChunks: totalChunks,
          samples: samples.sublist(
            startIndex,
            endIndex > samples.length ? samples.length : endIndex,
          ),
        ),
      );
    }

    return chunks;
  }
}
