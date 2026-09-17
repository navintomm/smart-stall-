import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../settings/domain/models/routine.dart';
import '../../../settings/domain/models/routine_frame.dart';

enum PlaybackStatus { idle, playing, paused, completed }

class PlaybackState {
  final PlaybackStatus status;
  final Routine? activeRoutine;
  final int currentFrameIndex;

  const PlaybackState({
    this.status = PlaybackStatus.idle,
    this.activeRoutine,
    this.currentFrameIndex = 0,
  });

  PlaybackState copyWith({
    PlaybackStatus? status,
    Routine? activeRoutine,
    int? currentFrameIndex,
  }) {
    return PlaybackState(
      status: status ?? this.status,
      activeRoutine: activeRoutine ?? this.activeRoutine,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
    );
  }
}

final routinePlaybackProvider = StateNotifierProvider<RoutinePlaybackNotifier, PlaybackState>((ref) {
  return RoutinePlaybackNotifier(ref);
});

class RoutinePlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref _ref;
  Timer? _playbackTimer;
  int _lastFrameTimeMs = 0;

  RoutinePlaybackNotifier(this._ref) : super(const PlaybackState());

  void start(Routine routine) {
    _stopTimer();
    state = PlaybackState(
      status: PlaybackStatus.playing,
      activeRoutine: routine,
      currentFrameIndex: 0,
    );
    _lastFrameTimeMs = 0;
    _playNextFrame();
  }

  void pause() {
    if (state.status == PlaybackStatus.playing) {
      _stopTimer();
      state = state.copyWith(status: PlaybackStatus.paused);
    }
  }

  void resume() {
    if (state.status == PlaybackStatus.paused && state.activeRoutine != null) {
      state = state.copyWith(status: PlaybackStatus.playing);
      _playNextFrame();
    }
  }

  void stop() {
    _stopTimer();
    state = const PlaybackState();
  }

  void _playNextFrame() {
    if (state.status != PlaybackStatus.playing || state.activeRoutine == null) {
      return;
    }

    final routine = state.activeRoutine!;
    if (state.currentFrameIndex >= routine.frames.length) {
      // Finished
      state = state.copyWith(status: PlaybackStatus.completed);
      return;
    }

    final frame = routine.frames[state.currentFrameIndex];
    final delayMs = frame.timestampMs - _lastFrameTimeMs;

    if (delayMs <= 0) {
      _executeFrameAndScheduleNext(frame);
    } else {
      _playbackTimer = Timer(Duration(milliseconds: delayMs), () {
        _executeFrameAndScheduleNext(frame);
      });
    }
  }

  void _executeFrameAndScheduleNext(RoutineFrame frame) {
    final repo = _ref.read(robotRepositoryProvider);

    // Execute servo commands
    frame.servoAngles.forEach((servoId, angle) {
      repo.moveServo(servoId, angle.round());
    });

    _lastFrameTimeMs = frame.timestampMs;
    state = state.copyWith(currentFrameIndex: state.currentFrameIndex + 1);

    // Schedule next
    _playNextFrame();
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
