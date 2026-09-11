import 'motion_sample.dart';
import 'routine.dart';
import 'routine_frame.dart';

/// A complete recorded trajectory from a human demonstration.
class MotionRecording {
  final String id;
  final String name;
  final List<MotionSample> samples;
  final DateTime createdAt;
  final int durationMs;

  const MotionRecording({
    required this.id,
    required this.name,
    required this.samples,
    required this.createdAt,
    required this.durationMs,
  });

  MotionRecording copyWith({
    String? id,
    String? name,
    List<MotionSample>? samples,
    DateTime? createdAt,
    int? durationMs,
  }) {
    return MotionRecording(
      id: id ?? this.id,
      name: name ?? this.name,
      samples: samples ?? this.samples,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  String get formattedDuration {
    final secs = (durationMs / 1000).toStringAsFixed(1);
    return '${secs}s';
  }

  /// Converts this MotionRecording into an executable Routine for the Motion Library.
  Routine toRoutine() {
    final frames = samples.map((sample) {
      return RoutineFrame(
        timestampMs: sample.timestampMs,
        servoAngles: {
          's1': sample.servo1Angle,
          's2': sample.servo2Angle,
          // other servos can default to their current state or safe values if needed
          // Since the prompt specifies focusing only on s1 and s2 for this checkpoint, 
          // we map them explicitly. In reality, a routine could need more.
        },
      );
    }).toList();

    return Routine(
      id: id,
      name: name,
      frames: frames,
      createdAt: createdAt,
      durationMs: durationMs,
    );
  }
}
