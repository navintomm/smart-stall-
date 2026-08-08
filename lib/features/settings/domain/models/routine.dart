import 'routine_frame.dart';

/// A complete recorded cleaning routine.
class Routine {
  final String id;
  final String name;
  final List<RoutineFrame> frames;
  final DateTime createdAt;
  final int durationMs;

  const Routine({
    required this.id,
    required this.name,
    required this.frames,
    required this.createdAt,
    required this.durationMs,
  });

  Routine copyWith({
    String? id,
    String? name,
    List<RoutineFrame>? frames,
    DateTime? createdAt,
    int? durationMs,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      frames: frames ?? this.frames,
      createdAt: createdAt ?? this.createdAt,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  String get formattedDuration {
    final secs = (durationMs / 1000).toStringAsFixed(1);
    return '${secs}s';
  }
}
