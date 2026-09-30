import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/models/dmp_trajectory_sample.dart';
import 'package:smartstall_operator/features/dmp_preview/domain/services/trajectory_chunker.dart';

void main() {
  group('TrajectoryChunker', () {
    List<DmpTrajectorySample> createSamples(int count) {
      return List.generate(
        count,
        (i) => DmpTrajectorySample(
          timeSeconds: i * 0.01,
          servo1Angle: 90.0 + i,
          servo2Angle: 90.0 - i,
        ),
      );
    }

    test('chunkTrajectory returns empty for empty samples', () {
      final chunks = TrajectoryChunker.chunkTrajectory([]);
      expect(chunks, isEmpty);
    });

    test('chunkTrajectory correctly chunks smaller than max size', () {
      final samples = createSamples(10);
      final chunks = TrajectoryChunker.chunkTrajectory(samples);

      expect(chunks.length, 1);
      expect(chunks[0].chunkIndex, 0);
      expect(chunks[0].totalChunks, 1);
      expect(chunks[0].samples.length, 10);
    });

    test('chunkTrajectory correctly chunks exact max size', () {
      final samples = createSamples(20);
      final chunks = TrajectoryChunker.chunkTrajectory(samples);

      expect(chunks.length, 1);
      expect(chunks[0].chunkIndex, 0);
      expect(chunks[0].totalChunks, 1);
      expect(chunks[0].samples.length, 20);
    });

    test('chunkTrajectory correctly chunks larger than max size', () {
      final samples = createSamples(45);
      final chunks = TrajectoryChunker.chunkTrajectory(samples);

      expect(chunks.length, 3);
      
      expect(chunks[0].chunkIndex, 0);
      expect(chunks[0].samples.length, 20);
      
      expect(chunks[1].chunkIndex, 1);
      expect(chunks[1].samples.length, 20);
      
      expect(chunks[2].chunkIndex, 2);
      expect(chunks[2].samples.length, 5); // Remainder
      
      for (final chunk in chunks) {
        expect(chunk.totalChunks, 3);
      }
    });

    test('toJsonPayload serializes exactly as expected by ESP32 ProtocolCodec', () {
      const sample = DmpTrajectorySample(
        timeSeconds: 1.234, // 1234 ms
        servo1Angle: 45.67, // rounds to 45.7
        servo2Angle: 120.12, // rounds to 120.1
      );
      final chunk = TrajectoryChunker.chunkTrajectory([sample]).first;

      final payload = chunk.toJsonPayload();
      expect(payload.length, 1);
      expect(payload[0], equals([1234, 45.7, 120.1]));
    });
  });
}
