import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/dmp_joint_metrics.dart';
import '../../domain/models/dmp_result.dart';
import '../../domain/models/dmp_trajectory_sample.dart';
import '../../data/repositories/dmp_result_repository.dart';
import '../../../settings/domain/models/routine.dart';

/// Enum for trajectory comparison mode.
enum TrajectoryViewMode { original, dmp, compare }

/// Enum for playback state.
enum PlaybackStatus { idle, playing, paused }

/// State for the DMP Motion Preview screen.
class DmpPreviewState {
  final DmpResult? result;
  final bool isLoading;
  final String? errorMessage;

  final TrajectoryViewMode viewMode;
  final PlaybackStatus playbackStatus;

  /// Normalised playback progress: 0.0 – 1.0
  final double playbackProgress;
  final double playbackSpeed;
  final bool showTrail;

  const DmpPreviewState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
    this.viewMode = TrajectoryViewMode.dmp,
    this.playbackStatus = PlaybackStatus.idle,
    this.playbackProgress = 0.0,
    this.playbackSpeed = 1.0,
    this.showTrail = true,
  });

  DmpPreviewState copyWith({
    DmpResult? result,
    bool? isLoading,
    String? errorMessage,
    TrajectoryViewMode? viewMode,
    PlaybackStatus? playbackStatus,
    double? playbackProgress,
    double? playbackSpeed,
    bool? showTrail,
    bool clearError = false,
  }) {
    return DmpPreviewState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      viewMode: viewMode ?? this.viewMode,
      playbackStatus: playbackStatus ?? this.playbackStatus,
      playbackProgress: playbackProgress ?? this.playbackProgress,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      showTrail: showTrail ?? this.showTrail,
    );
  }

  /// Current sample index based on playback progress.
  int currentIndex(List<DmpTrajectorySample> samples) {
    if (samples.isEmpty) return 0;
    return (playbackProgress * (samples.length - 1)).round().clamp(0, samples.length - 1);
  }

  /// Active samples to display, depending on view mode.
  List<DmpTrajectorySample> activeSamples(DmpResult r) {
    return viewMode == TrajectoryViewMode.original ? r.originalSamples : r.generatedSamples;
  }
}

/// Provider: holds all DMP preview state.
final dmpPreviewProvider =
    StateNotifierProvider.autoDispose<DmpPreviewNotifier, DmpPreviewState>((ref) {
  return DmpPreviewNotifier();
});

class DmpPreviewNotifier extends StateNotifier<DmpPreviewState> {
  DmpPreviewNotifier() : super(const DmpPreviewState());

  // ──── Loading ─────────────────────────────────────────────────────────────

  /// Loads a DMP result synthesised from [routine].
  ///
  /// In this checkpoint the DMP computation is performed locally in Dart
  /// using the same mathematical formulation as the Python pipeline.
  /// This avoids a runtime dependency on the Python subprocess and keeps
  /// the preview self-contained and testable.
  void loadFromRoutine(Routine routine) {
    if (routine.frames.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Routine "${routine.name}" has no recorded frames.',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = _computeDmpLocally(routine);
      state = state.copyWith(
        result: result,
        isLoading: false,
        playbackProgress: 0.0,
        playbackStatus: PlaybackStatus.idle,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'DMP computation failed: $e',
      );
    }
  }

  /// Loads a [DmpResult] directly (e.g. from fixture data or a future service).
  void loadResult(DmpResult result) {
    state = state.copyWith(
      result: result,
      isLoading: false,
      playbackProgress: 0.0,
      playbackStatus: PlaybackStatus.idle,
      clearError: true,
    );
  }

  // ──── Playback controls ────────────────────────────────────────────────────

  void play() {
    if (state.result == null) return;
    state = state.copyWith(playbackStatus: PlaybackStatus.playing);
  }

  void pause() {
    state = state.copyWith(playbackStatus: PlaybackStatus.paused);
  }

  void restart() {
    state = state.copyWith(
      playbackProgress: 0.0,
      playbackStatus: PlaybackStatus.idle,
    );
  }

  void updateProgress(double progress) {
    state = state.copyWith(
      playbackProgress: progress.clamp(0.0, 1.0),
    );
  }

  void onPlaybackComplete() {
    state = state.copyWith(
      playbackStatus: PlaybackStatus.paused,
      playbackProgress: 1.0,
    );
  }

  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  void setViewMode(TrajectoryViewMode mode) {
    state = state.copyWith(viewMode: mode, playbackProgress: 0.0, playbackStatus: PlaybackStatus.idle);
  }

  void toggleTrail() {
    state = state.copyWith(showTrail: !state.showTrail);
  }

  // ──── Approval ─────────────────────────────────────────────────────────────

  /// Marks this result as approved for future (offline) use.
  ///
  /// SAFETY: This does NOT send any data to BLE, ESP32, or physical servos.
  void approve() {
    if (state.result == null) return;
    state = state.copyWith(result: state.result!.copyWith(isApproved: true));
  }

  /// Rejects the result and resets to idle.
  void reject() {
    state = state.copyWith(
      result: state.result?.copyWith(isApproved: false),
      playbackProgress: 0.0,
      playbackStatus: PlaybackStatus.idle,
    );
  }

  // ──── Local DMP computation ────────────────────────────────────────────────

  /// Computes a DMP trajectory from [routine] using Dart arithmetic.
  ///
  /// Implements:
  ///   Canonical system: s_dot = -alpha_s * s / tau
  ///   Transformation system: dz = alpha_z*(beta_z*(g - y) - z) + f
  ///   Basis functions: Gaussian with LWR weight learning
  ///   Preprocessing: boundary-clamped finite differences
  DmpResult _computeDmpLocally(Routine routine) {
    const int nBfs = 50;
    const double alphaZ = 25.0;
    const double betaZ = 6.25;
    const double alphaS = 4.60517; // ln(100)

    final frames = routine.frames;
    final n = frames.length;

    // Build time vector (seconds)
    final t = List<double>.generate(n, (i) => frames[i].timestampMs / 1000.0);
    final tau = t.last - t.first;
    if (tau <= 0) throw ArgumentError('Duration must be positive');
    final dt = tau / (n - 1);

    // Extract positions
    final y1 = List<double>.generate(n, (i) => frames[i].servoAngles['s1'] ?? 0.0);
    final y2 = List<double>.generate(n, (i) => frames[i].servoAngles['s2'] ?? 0.0);

    // Phase-space rollout
    final sTrack = _rollout(n, alphaS, dt, tau);

    // Basis function centres and widths
    final centres = List<double>.generate(
        nBfs, (i) => exp(-alphaS * i / (nBfs - 1)));
    final widths = List<double>.generate(
        nBfs, (i) => nBfs * sqrt(nBfs.toDouble()) / centres[i] / alphaS);

    // Per-joint DMP
    final gen1 = _runDmp(y1, sTrack, centres, widths, alphaZ, betaZ, dt, tau, n);
    final gen2 = _runDmp(y2, sTrack, centres, widths, alphaZ, betaZ, dt, tau, n);

    // Build generated samples (original samples are built inside the repository)
    final generatedSamples = List<DmpTrajectorySample>.generate(
      n,
      (i) => DmpTrajectorySample(
        timeSeconds: t[i],
        servo1Angle: gen1[i],
        servo2Angle: gen2[i],
      ),
    );

    final m1 = _computeMetrics('servo1_angle', y1, gen1);
    final m2 = _computeMetrics('servo2_angle', y2, gen2);

    final startOk1 = (y1.first - gen1.first).abs() <= 0.1;
    final startOk2 = (y2.first - gen2.first).abs() <= 0.1;
    final goalOk1 = (y1.last - gen1.last).abs() <= 1.5;
    final goalOk2 = (y2.last - gen2.last).abs() <= 1.5;

    return DmpResultRepository.fromRoutineWithDmpOutput(
      originalRoutine: routine,
      generatedSamples: generatedSamples,
      servo1Metrics: m1,
      servo2Metrics: m2,
      startPreserved: startOk1 && startOk2,
      goalPreserved: goalOk1 && goalOk2,
    );
  }

  List<double> _rollout(int n, double alphaS, double dt, double tau) {
    double s = 1.0;
    final track = <double>[];
    for (int i = 0; i < n; i++) {
      track.add(s);
      s += (-alphaS * s) * (dt / tau);
    }
    return track;
  }

  List<double> _runDmp(
    List<double> y,
    List<double> sTrack,
    List<double> c,
    List<double> h,
    double alphaZ,
    double betaZ,
    double dt,
    double tau,
    int steps,
  ) {
    final int nBfs = c.length;
    final double goal = y.last;
    final double start = y.first;

    // Smooth position & finite-difference derivatives
    final ySmooth = List<double>.from(y);
    final dy = List<double>.filled(steps, 0.0);
    final ddy = List<double>.filled(steps, 0.0);

    // Boundary clamp (mirrors Python preprocessing)
    for (int i = 0; i < min(10, steps); i++) {
      ySmooth[i] = ySmooth[min(10, steps - 1)];
    }
    for (int i = max(0, steps - 10); i < steps; i++) {
      ySmooth[i] = ySmooth[max(0, steps - 11)];
    }

    for (int i = 1; i < steps - 1; i++) {
      dy[i] = (ySmooth[i + 1] - ySmooth[i - 1]) / (2 * dt);
      ddy[i] = (ySmooth[i + 1] - 2 * ySmooth[i] + ySmooth[i - 1]) / (dt * dt);
    }

    // Force boundary velocities/accels to 0
    for (int i = 0; i < min(10, steps); i++) { dy[i] = 0; ddy[i] = 0; }
    for (int i = max(0, steps - 10); i < steps; i++) { dy[i] = 0; ddy[i] = 0; }

    // LWR weight learning
    final fTarget = List<double>.generate(steps, (i) {
      return (tau * tau * ddy[i]) - alphaZ * (betaZ * (goal - ySmooth[i]) - tau * dy[i]);
    });

    final weights = List<double>.filled(nBfs, 0.0);
    for (int j = 0; j < nBfs; j++) {
      final psi = sTrack.map((s) => exp(-h[j] * (s - c[j]) * (s - c[j]))).toList();
      double num = 0, den = 0;
      for (int i = 0; i < steps; i++) {
        num += sTrack[i] * psi[i] * fTarget[i];
        den += sTrack[i] * sTrack[i] * psi[i];
      }
      weights[j] = num / (den + 1e-10);
    }

    // Generate trajectory
    final generated = <double>[];
    double posY = start;
    double posZ = 0.0;

    // Reset phase
    double s = 1.0;
    for (int i = 0; i < steps; i++) {
      final psi = List<double>.generate(nBfs, (j) => exp(-h[j] * (s - c[j]) * (s - c[j])));
      final sumPsi = psi.reduce((a, b) => a + b) + 1e-10;
      final f = weights.indexed.fold(0.0, (acc, rec) => acc + rec.$2 * psi[rec.$1]) / sumPsi * s;

      final dz = alphaZ * (betaZ * (goal - posY) - posZ) + f;
      final dyNext = posZ;

      posZ += dz * (dt / tau);
      posY += dyNext * (dt / tau);
      s += (-4.60517 * s) * (dt / tau);

      generated.add(posY);
    }

    return generated;
  }

  DmpJointMetrics _computeMetrics(
      String name, List<double> original, List<double> generated) {
    final n = original.length;
    double sumAbs = 0, sumSq = 0, maxErr = 0;

    for (int i = 0; i < n; i++) {
      final err = (original[i] - generated[i]).abs();
      sumAbs += err;
      sumSq += err * err;
      if (err > maxErr) maxErr = err;
    }

    double smoothOrig = 0, smoothGen = 0;
    if (n >= 4) {
      for (int i = 0; i < n - 3; i++) {
        final j3o = original[i + 3] - 3 * original[i + 2] + 3 * original[i + 1] - original[i];
        final j3g = generated[i + 3] - 3 * generated[i + 2] + 3 * generated[i + 1] - generated[i];
        smoothOrig += j3o * j3o;
        smoothGen += j3g * j3g;
      }
    }

    return DmpJointMetrics(
      jointName: name,
      mae: sumAbs / n,
      rmse: sqrt(sumSq / n),
      maxError: maxErr,
      smoothnessOriginal: smoothOrig,
      smoothnessGenerated: smoothGen,
    );
  }
}
