import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../connection/presentation/providers/bluetooth_provider.dart';
import '../../domain/models/routine.dart';

enum HwPlaybackStatus { idle, waitingReady, sending, waitingDataReceived, playing, finished, error }

class HwPlaybackState {
  final HwPlaybackStatus status;
  final int pointIndex;
  final int totalPoints;
  final String? errorMessage;

  const HwPlaybackState({
    this.status = HwPlaybackStatus.idle,
    this.pointIndex = 0,
    this.totalPoints = 0,
    this.errorMessage,
  });

  HwPlaybackState copyWith({
    HwPlaybackStatus? status,
    int? pointIndex,
    int? totalPoints,
    String? errorMessage,
  }) {
    return HwPlaybackState(
      status: status ?? this.status,
      pointIndex: pointIndex ?? this.pointIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      errorMessage: errorMessage,
    );
  }
}

class HardwarePlaybackNotifier extends StateNotifier<HwPlaybackState> {
  final BluetoothStateNotifier _btNotifier;
  StreamSubscription<String>? _dataSub;
  Completer<String>? _responseCompleter;

  HardwarePlaybackNotifier(this._btNotifier) : super(const HwPlaybackState());

  /// Play a routine using the hardware handshake protocol:
  /// "P" → wait "READY_FOR_DATA" → send points → "E\n" → wait "DATA_RECEIVED" → wait "PLAYBACK_FINISHED"
  Future<void> playRoutine(Routine routine) async {
    if (state.status != HwPlaybackStatus.idle) return;

    final btState = _btNotifier.state;
    if (!btState.isConnected) {
      state = state.copyWith(
        status: HwPlaybackStatus.error,
        errorMessage: 'Not connected to hardware',
      );
      return;
    }

    final frames = routine.frames;
    if (frames.isEmpty) {
      state = state.copyWith(
        status: HwPlaybackStatus.error,
        errorMessage: 'No frames in routine',
      );
      return;
    }

    state = HwPlaybackState(
      status: HwPlaybackStatus.waitingReady,
      totalPoints: frames.length,
    );

    // Set up response listener
    _dataSub?.cancel();
    _dataSub = _btNotifier.incomingData.listen(_handleResponse);

    try {
      // Step 1: Send "P" and wait for "READY_FOR_DATA" (5s timeout)
      await _btNotifier.sendCommand('P');
      final readyResponse = await _waitForResponse('READY_FOR_DATA', timeout: const Duration(seconds: 5));
      if (readyResponse == null) {
        state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Timeout: no READY_FOR_DATA');
        _cleanup();
        return;
      }

      // Step 2: Send all points
      state = state.copyWith(status: HwPlaybackStatus.sending);
      final isBle = btState.activeType == ConnectionType.ble;
      final delayMs = isBle ? 50 : 10;

      for (int i = 0; i < frames.length; i++) {
        if (state.status == HwPlaybackStatus.error) return; // cancelled

        final frame = frames[i];
        final s1 = frame.servoAngles['s1']?.toInt() ?? 0;
        final s2 = frame.servoAngles['s2']?.toInt() ?? 0;
        final stepper = frame.servoAngles['stepper']?.toInt() ?? 0;
        final line = '$s1,$s2,$stepper\n';

        await _btNotifier.sendCommand(line);
        state = state.copyWith(pointIndex: i + 1);

        await Future.delayed(Duration(milliseconds: delayMs));
      }

      // Step 3: Send end marker
      await _btNotifier.sendCommand('E\n');

      // Step 4: Wait for "DATA_RECEIVED" (30s timeout)
      state = state.copyWith(status: HwPlaybackStatus.waitingDataReceived);
      final dataResponse = await _waitForResponse('DATA_RECEIVED', timeout: const Duration(seconds: 30));
      if (dataResponse == null) {
        state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Timeout: no DATA_RECEIVED');
        _cleanup();
        return;
      }

      // Step 5: Wait for "PLAYBACK_FINISHED" (120s timeout)
      state = state.copyWith(status: HwPlaybackStatus.playing);
      final finishResponse = await _waitForResponse('PLAYBACK_FINISHED', timeout: const Duration(seconds: 120));
      if (finishResponse == null) {
        state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Timeout: PLAYBACK_FINISHED not received');
        _cleanup();
        return;
      }

      state = state.copyWith(status: HwPlaybackStatus.finished);
    } catch (e) {
      state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: e.toString());
    } finally {
      _cleanup();
    }
  }

  void _handleResponse(String line) {
    final clean = line.trim();
    debugPrint('[HwPlayback] Received: $clean');

    // Handle error responses
    if (clean == 'NOTHING_TO_PLAY') {
      state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Hardware: nothing to play');
      _responseCompleter?.complete(clean);
      return;
    }
    if (clean == 'TIMEOUT') {
      state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Hardware: timeout during playback');
      _responseCompleter?.complete(clean);
      return;
    }
    if (clean.startsWith('POINT_SKIPPED,')) {
      debugPrint('[HwPlayback] WARNING: $clean');
    }

    // Complete any pending waiter
    if (_responseCompleter != null && !_responseCompleter!.isCompleted) {
      _responseCompleter!.complete(clean);
    }
  }

  Future<String?> _waitForResponse(String expected, {required Duration timeout}) async {
    _responseCompleter = Completer<String>();
    try {
      while (true) {
        final result = await _responseCompleter!.future.timeout(timeout, onTimeout: () => '__TIMEOUT__');
        if (result == '__TIMEOUT__') return null;
        if (result == expected || result == 'NOTHING_TO_PLAY' || result == 'TIMEOUT') return result == expected ? result : null;
        // Not the expected response — keep waiting
        _responseCompleter = Completer<String>();
      }
    } catch (_) {
      return null;
    }
  }

  void stopPlayback() {
    state = state.copyWith(status: HwPlaybackStatus.error, errorMessage: 'Cancelled by user');
    _responseCompleter?.complete('__CANCELLED__');
    _cleanup();
  }

  void reset() {
    state = const HwPlaybackState();
  }

  void _cleanup() {
    _dataSub?.cancel();
    _dataSub = null;
  }

  @override
  void dispose() {
    _dataSub?.cancel();
    super.dispose();
  }
}

final hardwarePlaybackProvider =
    StateNotifierProvider<HardwarePlaybackNotifier, HwPlaybackState>((ref) {
  final btNotifier = ref.watch(bluetoothProvider.notifier);
  return HardwarePlaybackNotifier(btNotifier);
});
