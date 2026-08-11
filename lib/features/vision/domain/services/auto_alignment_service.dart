import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/di_providers.dart';
import '../../../../core/repositories/robot_repository.dart';
import '../../../../core/communication/protocol/catalogues/command_catalog.dart';
import '../models/alignment_result.dart';
import '../../presentation/providers/alignment_provider.dart';
import '../../../connection/presentation/providers/connection_provider.dart';
import '../../../manual_control/presentation/providers/manual_control_provider.dart';

// ─── State ───────────────────────────────────────────────────────────────────

enum AutoAlignState {
  idle,
  searching,
  tracking,
  aligningDistance,
  aligningHorizontal,
  aligningRotation,
  aligned,
  markerLost,
  error,
  stopped,
}

class AutoAlignmentState {
  final AutoAlignState status;
  final String lastCommand;
  final int stableFrameCount;

  const AutoAlignmentState({
    this.status = AutoAlignState.idle,
    this.lastCommand = '',
    this.stableFrameCount = 0,
  });

  bool get isAutoAlignActive => 
      status == AutoAlignState.searching || 
      status == AutoAlignState.tracking ||
      status == AutoAlignState.aligningDistance ||
      status == AutoAlignState.aligningHorizontal ||
      status == AutoAlignState.aligningRotation;

  AutoAlignmentState copyWith({
    AutoAlignState? status,
    String? lastCommand,
    int? stableFrameCount,
  }) {
    return AutoAlignmentState(
      status: status ?? this.status,
      lastCommand: lastCommand ?? this.lastCommand,
      stableFrameCount: stableFrameCount ?? this.stableFrameCount,
    );
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final autoAlignmentServiceProvider =
    StateNotifierProvider<AutoAlignmentNotifier, AutoAlignmentState>((ref) {
  final robot = ref.watch(robotRepositoryProvider);
  final notifier = AutoAlignmentNotifier(robot);

  ref.listen(manualControlProvider.select((s) => s.emergencyStopEngaged), (_, isEStop) {
    notifier.updateSafety(isEStop: isEStop);
  });
  
  ref.listen(connectionProvider.select((s) => s.activeRobot?.status == 'Connected'), (_, isConnected) {
    notifier.updateSafety(isConnected: isConnected);
  });

  notifier.updateSafety(
    isEStop: ref.read(manualControlProvider).emergencyStopEngaged,
    isConnected: ref.read(connectionProvider).activeRobot?.status == 'Connected',
  );

  // Listen to smoothed alignment updates and forward them
  ref.listen<AlignmentResult>(smoothedAlignmentProvider, (previous, next) {
    notifier.processAlignment(next);
  });

  ref.onDispose(() => notifier.dispose());

  return notifier;
});

// ─── Notifier ────────────────────────────────────────────────────────────────

class AutoAlignmentNotifier extends StateNotifier<AutoAlignmentState> {
  final RobotRepository _robot;

  // Throttle
  DateTime _lastCommandTime = DateTime.now();
  static const int _minCommandIntervalMs = 150;

  // Safety timeout — if no vision update for this long, STOP
  Timer? _safetyTimer;
  static const int _safetyTimeoutMs = 800;

  // Stability
  static const int _stableFramesRequired = 5;

  // Deadbands
  static const double _distanceDeadbandM = 0.03; // ±3 cm
  static const double _horizontalDeadbandM = 0.03; // ±3 cm

  bool _isEmergencyStop = false;
  bool _isConnected = false;

  AutoAlignmentNotifier(this._robot)
      : super(const AutoAlignmentState());

  void updateSafety({bool? isEStop, bool? isConnected}) {
    if (isEStop != null) _isEmergencyStop = isEStop;
    if (isConnected != null) _isConnected = isConnected;

    if (_isEmergencyStop || !_isConnected) {
      if (state.isAutoAlignActive) {
        _sendCommand(CommandCatalog.stop.name, {});
        state = state.copyWith(
          status: AutoAlignState.error,
          lastCommand: _isEmergencyStop ? 'STOP (E-Stop)' : 'STOP (Disconnected)',
        );
      }
    }
  }

  // ── Public API ──────────────────────────────────────────────────────────

  void startAutoAlignment() {
    if (state.isAutoAlignActive) return;
    state = state.copyWith(
      status: AutoAlignState.searching,
      stableFrameCount: 0,
      lastCommand: '',
    );
    _resetSafetyTimer();
  }

  void stopAutoAlignment() {
    _safetyTimer?.cancel();
    _sendCommand(CommandCatalog.stop.name, {});
    state = state.copyWith(
      status: AutoAlignState.stopped,
      stableFrameCount: 0,
    );
  }

  // ── Core Alignment Loop ─────────────────────────────────────────────────

  void processAlignment(AlignmentResult alignment) {
    if (!state.isAutoAlignActive) return;

    // Reset safety timer on every valid frame
    _resetSafetyTimer();

    // ── Safety: Global Safety or Marker lost ──────────────────────────────
    if (_isEmergencyStop || !_isConnected) {
      _sendCommand(CommandCatalog.stop.name, {});
      state = state.copyWith(
        status: AutoAlignState.error,
        stableFrameCount: 0,
        lastCommand: _isEmergencyStop ? 'STOP (E-Stop)' : 'STOP (Disconnected)',
      );
      return;
    }

    if (alignment.status == AlignmentStatus.markerLost ||
        alignment.status == AlignmentStatus.error ||
        alignment.status == AlignmentStatus.scanning) {
      _sendCommand(CommandCatalog.stop.name, {});
      state = state.copyWith(
        status: alignment.status == AlignmentStatus.scanning ? AutoAlignState.searching : AutoAlignState.markerLost,
        stableFrameCount: 0,
        lastCommand: alignment.status == AlignmentStatus.scanning ? 'STOP (Scanning)' : 'STOP (Marker Lost)',
      );
      return;
    }

    // ── Throttle ──────────────────────────────────────────────────────────
    final now = DateTime.now();
    if (now.difference(_lastCommandTime).inMilliseconds < _minCommandIntervalMs) {
      return;
    }

    // ── Check if within deadband ──────────────────────────────────────────
    final distErr = alignment.distanceErrorM; // signed
    final horizErr = alignment.horizontalErrorM; // signed

    final distanceInBand = distErr.abs() <= _distanceDeadbandM;
    final horizontalInBand = horizErr.abs() <= _horizontalDeadbandM;

    if (distanceInBand && horizontalInBand) {
      // Within tolerance — accumulate stable frames
      final newCount = state.stableFrameCount + 1;
      if (newCount >= _stableFramesRequired) {
        _sendCommand(CommandCatalog.stop.name, {});
        state = state.copyWith(
          status: AutoAlignState.aligned,
          stableFrameCount: newCount,
          lastCommand: 'ALIGNED',
        );
        _safetyTimer?.cancel();
        return;
      }
      state = state.copyWith(
        stableFrameCount: newCount,
        status: AutoAlignState.tracking,
      );
      return;
    }

    // Reset stable counter when outside band
    if (state.stableFrameCount > 0) {
      state = state.copyWith(stableFrameCount: 0);
    }

    // ── Proportional control ──────────────────────────────────────────────
    // Prioritise horizontal alignment first, then distance
    if (!horizontalInBand) {
      final speed = (horizErr.abs() * 80).clamp(12, 40).toInt();
      if (horizErr > 0) {
        _sendCommand(CommandCatalog.turnRight.name, {'speed': speed});
        state = state.copyWith(
          lastCommand: 'TURN_RIGHT ($speed)',
          status: AutoAlignState.aligningHorizontal,
        );
      } else {
        _sendCommand(CommandCatalog.turnLeft.name, {'speed': speed});
        state = state.copyWith(
          lastCommand: 'TURN_LEFT ($speed)',
          status: AutoAlignState.aligningHorizontal,
        );
      }
    } else if (!distanceInBand) {
      final speed = (distErr.abs() * 60).clamp(12, 45).toInt();
      if (distErr > 0) {
        _sendCommand(CommandCatalog.moveForward.name, {'speed': speed});
        state = state.copyWith(
          lastCommand: 'FORWARD ($speed)',
          status: AutoAlignState.aligningDistance,
        );
      } else {
        _sendCommand(CommandCatalog.moveBackward.name, {'speed': speed});
        state = state.copyWith(
          lastCommand: 'BACKWARD ($speed)',
          status: AutoAlignState.aligningDistance,
        );
      }
    }
  }

  // ── Internals ──────────────────────────────────────────────────────────

  void _sendCommand(String command, Map<String, dynamic> payload) {
    _robot.sendCommand(command, payload);
    _lastCommandTime = DateTime.now();
  }

  void _resetSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = Timer(
      const Duration(milliseconds: _safetyTimeoutMs),
      () {
        // No vision update received — emergency stop
        if (state.isAutoAlignActive) {
          _sendCommand(CommandCatalog.stop.name, {});
          state = state.copyWith(
            status: AutoAlignState.error,
            lastCommand: 'STOP (safety timeout)',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }
}
