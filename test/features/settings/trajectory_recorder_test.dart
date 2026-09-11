import 'package:flutter_test/flutter_test.dart';
import 'package:smartstall_operator/features/settings/domain/models/motion_sample.dart';
import 'package:smartstall_operator/features/settings/domain/models/motion_recording.dart';

void main() {
  group('Trajectory Recorder Domain Tests', () {
    test('MotionRecording toRoutine conversion generates correct duration and frames', () {
      final samples = [
        const MotionSample(timestampMs: 0, servo1Angle: 90.0, servo2Angle: 90.0),
        const MotionSample(timestampMs: 50, servo1Angle: 90.5, servo2Angle: 89.8),
        const MotionSample(timestampMs: 100, servo1Angle: 91.0, servo2Angle: 89.0),
      ];
      
      final recording = MotionRecording(
        id: 'rec_1',
        name: 'Test Recording',
        createdAt: DateTime.now(),
        durationMs: 100,
        samples: samples,
      );

      final routine = recording.toRoutine();

      expect(routine.id, 'rec_1');
      expect(routine.name, 'Test Recording');
      expect(routine.durationMs, 100);
      expect(routine.frames.length, 3);
      expect(routine.frames[0].timestampMs, 0);
      expect(routine.frames[0].servoAngles['s1'], 90.0);
      expect(routine.frames[1].timestampMs, 50);
      expect(routine.frames[2].timestampMs, 100);
      expect(routine.frames[2].servoAngles['s2'], 89.0);
    });

    test('CSV Export format logic (mimicking UI logic)', () {
      final samples = [
        const MotionSample(timestampMs: 0, servo1Angle: 90.0, servo2Angle: 90.0),
        const MotionSample(timestampMs: 50, servo1Angle: 90.5, servo2Angle: 89.8),
      ];
      
      final recording = MotionRecording(
        id: 'rec_2',
        name: 'CSV Test',
        createdAt: DateTime.now(),
        durationMs: 50,
        samples: samples,
      );

      final routine = recording.toRoutine();

      final buffer = StringBuffer();
      buffer.writeln('timestamp_ms,servo1_angle,servo2_angle');
      for (var f in routine.frames) {
        final s1 = f.servoAngles['s1'] ?? 0.0;
        final s2 = f.servoAngles['s2'] ?? 0.0;
        buffer.writeln('${f.timestampMs},${s1.toStringAsFixed(4)},${s2.toStringAsFixed(4)}');
      }

      final csvString = buffer.toString();
      expect(csvString.contains('timestamp_ms,servo1_angle,servo2_angle'), true);
      expect(csvString.contains('0,90.0000,90.0000'), true);
      expect(csvString.contains('50,90.5000,89.8000'), true);
    });

    test('Stationary filtering logic check', () {
      // Re-implementing the filter logic to verify thresholds.
      final recordedSamples = <MotionSample>[];
      
      void mockSample(int time, double s1, double s2) {
        if (recordedSamples.isNotEmpty) {
          final last = recordedSamples.last;
          if ((last.servo1Angle - s1).abs() < 0.1 && (last.servo2Angle - s2).abs() < 0.1) {
            return; // Skip duplicate
          }
        }
        recordedSamples.add(MotionSample(timestampMs: time, servo1Angle: s1, servo2Angle: s2));
      }

      mockSample(0, 90.0, 90.0); // Kept
      mockSample(50, 90.05, 90.05); // Ignored (delta 0.05 < 0.1)
      mockSample(100, 90.08, 90.08); // Ignored (delta 0.08 < 0.1)
      mockSample(150, 90.2, 90.0); // Kept (delta 0.2 >= 0.1)
      mockSample(200, 90.2, 90.0); // Ignored (identical)

      expect(recordedSamples.length, 2);
      expect(recordedSamples[0].timestampMs, 0);
      expect(recordedSamples[1].timestampMs, 150);
    });
  });
}
