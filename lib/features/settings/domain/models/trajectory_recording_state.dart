import 'motion_sample.dart';

enum RecordingStatus { idle, recording, saving }

/// State for the trajectory recording session.
class TrajectoryRecordingState {
  final RecordingStatus status;
  final List<MotionSample> samples;
  final int elapsedMs;
  final String? pendingRecordingName;

  const TrajectoryRecordingState({
    this.status = RecordingStatus.idle,
    this.samples = const [],
    this.elapsedMs = 0,
    this.pendingRecordingName,
  });

  bool get isRecording => status == RecordingStatus.recording;
  bool get isIdle => status == RecordingStatus.idle;

  TrajectoryRecordingState copyWith({
    RecordingStatus? status,
    List<MotionSample>? samples,
    int? elapsedMs,
    String? pendingRecordingName,
  }) {
    return TrajectoryRecordingState(
      status: status ?? this.status,
      samples: samples ?? this.samples,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      pendingRecordingName: pendingRecordingName ?? this.pendingRecordingName,
    );
  }
}
