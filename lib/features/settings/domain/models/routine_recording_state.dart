import 'routine_frame.dart';

enum RecordingStatus { idle, recording, saving }

/// State for the routine recording session.
class RoutineRecordingState {
  final RecordingStatus status;
  final List<RoutineFrame> frames;
  final int elapsedMs;
  final String? pendingRoutineName; // set when Save dialog is open

  const RoutineRecordingState({
    this.status = RecordingStatus.idle,
    this.frames = const [],
    this.elapsedMs = 0,
    this.pendingRoutineName,
  });

  bool get isRecording => status == RecordingStatus.recording;
  bool get isIdle => status == RecordingStatus.idle;

  RoutineRecordingState copyWith({
    RecordingStatus? status,
    List<RoutineFrame>? frames,
    int? elapsedMs,
    String? pendingRoutineName,
  }) {
    return RoutineRecordingState(
      status: status ?? this.status,
      frames: frames ?? this.frames,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      pendingRoutineName: pendingRoutineName ?? this.pendingRoutineName,
    );
  }
}
