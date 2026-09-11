import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trajectory_recording_state.dart';
import '../../domain/models/motion_sample.dart';
import '../../domain/models/motion_recording.dart';
import '../../../manual_control/presentation/providers/manual_control_provider.dart';
import 'motion_library_provider.dart';

final trajectoryRecordingProvider =
    StateNotifierProvider<TrajectoryRecordingNotifier, TrajectoryRecordingState>((ref) {
  return TrajectoryRecordingNotifier(ref);
});

class TrajectoryRecordingNotifier extends StateNotifier<TrajectoryRecordingState> {
  final Ref _ref;
  Timer? _pollingTimer;
  final Stopwatch _stopwatch = Stopwatch();

  TrajectoryRecordingNotifier(this._ref) : super(const TrajectoryRecordingState());

  /// Start recording: polls servo angles at 50ms intervals (20Hz).
  void startRecording() {
    if (state.isRecording) return;
    _stopwatch.reset();
    _stopwatch.start();
    state = const TrajectoryRecordingState(status: RecordingStatus.recording);

    _pollingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      // Read current state from manualControlProvider
      final servos = _ref.read(manualControlProvider).servos;
      final s1 = servos.firstWhere((s) => s.id == 's1', orElse: () => servos.first).currentAngle;
      final s2 = servos.firstWhere((s) => s.id == 's2', orElse: () => servos.first).currentAngle;

      // Prevent duplicate samples if completely stationary (delta < 0.1 degree)
      if (state.samples.isNotEmpty) {
        final lastSample = state.samples.last;
        final diffS1 = (lastSample.servo1Angle - s1).abs();
        final diffS2 = (lastSample.servo2Angle - s2).abs();
        if (diffS1 < 0.1 && diffS2 < 0.1) {
          // Stationary, skip to keep data compact
          // We still update the elapsed time without adding a sample.
          state = state.copyWith(elapsedMs: _stopwatch.elapsedMilliseconds);
          return;
        }
      }

      final sample = MotionSample(
        timestampMs: _stopwatch.elapsedMilliseconds,
        servo1Angle: s1,
        servo2Angle: s2,
      );
      state = state.copyWith(
        samples: [...state.samples, sample],
        elapsedMs: _stopwatch.elapsedMilliseconds,
      );
    });
  }

  /// Stop recording and transition to saving state.
  void stopRecording() {
    _pollingTimer?.cancel();
    _stopwatch.stop();
    if (state.samples.isEmpty) {
      state = const TrajectoryRecordingState();
      return;
    }
    state = state.copyWith(status: RecordingStatus.saving);
  }

  /// Discard the current recording and reset to idle.
  void discardRecording() {
    _pollingTimer?.cancel();
    _stopwatch.stop();
    state = const TrajectoryRecordingState();
  }

  /// Save the current recording as a named routine and reset.
  void saveAsRoutine(String name) {
    if (state.samples.isEmpty) return;
    
    final recording = MotionRecording(
      id: 'recording_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Untitled Recording' : name.trim(),
      samples: List.of(state.samples),
      createdAt: DateTime.now(),
      durationMs: state.elapsedMs,
    );

    // Convert to Routine to store in the existing motion library
    final routine = recording.toRoutine();
    
    _ref.read(motionLibraryProvider.notifier).saveRoutine(routine);
    state = const TrajectoryRecordingState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
