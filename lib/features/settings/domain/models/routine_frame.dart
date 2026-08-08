/// A single snapshot of servo angles at a given timestamp during recording.
class RoutineFrame {
  final int timestampMs;
  final Map<String, double> servoAngles; // servoId → angle in degrees

  const RoutineFrame({
    required this.timestampMs,
    required this.servoAngles,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'servoAngles': servoAngles,
      };

  factory RoutineFrame.fromJson(Map<String, dynamic> json) => RoutineFrame(
        timestampMs: json['timestampMs'] as int,
        servoAngles: Map<String, double>.from(
          (json['servoAngles'] as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
        ),
      );
}
