/// A single snapshot of human-demonstrated motion at a given timestamp.
class MotionSample {
  final int timestampMs;
  final double servo1Angle;
  final double servo2Angle;

  const MotionSample({
    required this.timestampMs,
    required this.servo1Angle,
    required this.servo2Angle,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'servo1Angle': servo1Angle,
        'servo2Angle': servo2Angle,
      };

  factory MotionSample.fromJson(Map<String, dynamic> json) => MotionSample(
        timestampMs: json['timestampMs'] as int,
        servo1Angle: (json['servo1Angle'] as num).toDouble(),
        servo2Angle: (json['servo2Angle'] as num).toDouble(),
      );
}
