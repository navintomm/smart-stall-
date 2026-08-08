import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/routine_recording_state.dart';
import '../../domain/models/routine_frame.dart';
import '../../domain/models/routine.dart';
import 'motion_library_provider.dart';

final routineRecordingProvider =
    StateNotifierProvider<RoutineRecordingNotifier, RoutineRecordingState>((ref) {
  return RoutineRecordingNotifier(ref);
});

class RoutineRecordingNotifier extends StateNotifier<RoutineRecordingState> {
  final Ref _ref;
  Timer? _pollingTimer;
  final Stopwatch _stopwatch = Stopwatch();

  // Simulated current servo angles (in a real app, read from telemetry stream)
  final Map<String, double> _currentAngles = {
    's1': 90.0,
    's2': 45.0,
    's3': 120.0,
    's4': 90.0,
    's5': 10.0,
  };

  RoutineRecordingNotifier(this._ref) : super(const RoutineRecordingState());

  /// Update a servo angle (called when user moves the joystick / sliders).
  void updateServoAngle(String servoId, double angle) {
    _currentAngles[servoId] = angle;
  }

  /// Start recording: polls servo angles at 100ms intervals.
  void startRecording() {
    if (state.isRecording) return;
    _stopwatch.reset();
    _stopwatch.start();
    state = const RoutineRecordingState(status: RecordingStatus.recording);

    _pollingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final frame = RoutineFrame(
        timestampMs: _stopwatch.elapsedMilliseconds,
        servoAngles: Map.of(_currentAngles),
      );
      state = state.copyWith(
        frames: [...state.frames, frame],
        elapsedMs: _stopwatch.elapsedMilliseconds,
      );
    });
  }

  /// Stop recording and transition to saving state.
  void stopRecording() {
    _pollingTimer?.cancel();
    _stopwatch.stop();
    if (state.frames.isEmpty) {
      state = const RoutineRecordingState();
      return;
    }
    state = state.copyWith(status: RecordingStatus.saving);
  }

  /// Discard the current recording and reset to idle.
  void discardRecording() {
    _pollingTimer?.cancel();
    _stopwatch.stop();
    state = const RoutineRecordingState();
  }

  /// Save the current recording as a named routine and reset.
  void saveAsRoutine(String name) {
    if (state.frames.isEmpty) return;
    final routine = Routine(
      id: 'routine_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Untitled Routine' : name.trim(),
      frames: List.of(state.frames),
      createdAt: DateTime.now(),
      durationMs: state.elapsedMs,
    );
    _ref.read(motionLibraryProvider.notifier).saveRoutine(routine);
    state = const RoutineRecordingState();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
