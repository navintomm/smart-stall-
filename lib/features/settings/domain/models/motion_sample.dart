/// A single snapshot of human-demonstrated motion at a given timestamp.
class MotionSample {
  final int timestampMs;
  final double servo1Angle;
  final double servo2Angle;
  final int stepperPosition;

  const MotionSample({
    required this.timestampMs,
    required this.servo1Angle,
    required this.servo2Angle,
    this.stepperPosition = 0,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'servo1Angle': servo1Angle,
        'servo2Angle': servo2Angle,
        'stepperPosition': stepperPosition,
      };

  factory MotionSample.fromJson(Map<String, dynamic> json) => MotionSample(
        timestampMs: json['timestampMs'] as int,
        servo1Angle: (json['servo1Angle'] as num).toDouble(),
        servo2Angle: (json['servo2Angle'] as num).toDouble(),
        stepperPosition: (json['stepperPosition'] as num?)?.toInt() ?? 0,
      );

  /// Converts from the testing app's triple format: "encoder1,encoder2,stepper"
  factory MotionSample.fromTriple(int timestampMs, int enc1, int enc2, int stepper) =>
      MotionSample(
        timestampMs: timestampMs,
        servo1Angle: enc1.toDouble(),
        servo2Angle: enc2.toDouble(),
        stepperPosition: stepper,
      );

  /// Serializes to the testing app's playback format: "enc1,enc2,stepper\n"
  String toPlaybackLine() => '$servo1Angle,$servo2Angle,$stepperPosition\n';
}
