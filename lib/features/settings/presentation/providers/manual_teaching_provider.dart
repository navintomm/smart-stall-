import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trajectory_recording_state.dart';
import '../../domain/models/motion_sample.dart';
import '../../domain/models/motion_recording.dart';
import 'motion_library_provider.dart';
import '../../../connection/presentation/providers/bluetooth_provider.dart';

final manualTeachingProvider =
    StateNotifierProvider<ManualTeachingNotifier, TrajectoryRecordingState>((ref) {
  final btNotifier = ref.watch(bluetoothProvider.notifier);
  return ManualTeachingNotifier(ref, btNotifier);
});

class ManualTeachingNotifier extends StateNotifier<TrajectoryRecordingState> {
  final Ref _ref;
  final BluetoothStateNotifier _btNotifier;
  StreamSubscription<String>? _dataSubscription;
  final Stopwatch _stopwatch = Stopwatch();

  /// Latest live values from hardware — exposed for UI display.
  int latestEncoder1 = 0;
  int latestEncoder2 = 0;
  int latestStepperPos = 0;
  bool teachStartedConfirmed = false;

  ManualTeachingNotifier(this._ref, this._btNotifier)
      : super(const TrajectoryRecordingState());

  void startTeaching() {
    if (state.isRecording) return;

    // Clear state and start
    _stopwatch.reset();
    _stopwatch.start();
    teachStartedConfirmed = false;
    latestEncoder1 = 0;
    latestEncoder2 = 0;
    latestStepperPos = 0;
    state = const TrajectoryRecordingState(status: RecordingStatus.recording);

    // Send the start command to hardware (works for both BLE and Classic)
    _btNotifier.sendCommand('T');

    // Listen to incoming lines (already assembled into complete lines by the service)
    _dataSubscription?.cancel();
    _dataSubscription = _btNotifier.incomingData.listen(_handleIncomingLine);
  }

  void _handleIncomingLine(String line) {
    final cleanLine = line.replaceAll('\r', '').replaceAll('\u0000', '').trim();
    if (cleanLine.isEmpty) return;

    // ── Protocol Responses ──────────────────────────────────────────────────
    if (cleanLine == 'TEACH_STARTED') {
      teachStartedConfirmed = true;
      debugPrint('[Teaching] Hardware confirmed TEACH_STARTED');
      return;
    }
    if (cleanLine == 'TEACH_STOPPED') {
      debugPrint('[Teaching] Hardware confirmed TEACH_STOPPED');
      return;
    }
    if (cleanLine == 'READY') {
      debugPrint('[Teaching] Hardware sent READY');
      return;
    }
    if (cleanLine.startsWith('STEPPER_POS,')) {
      final posStr = cleanLine.substring('STEPPER_POS,'.length);
      final pos = int.tryParse(posStr);
      if (pos != null) {
        latestStepperPos = pos;
        debugPrint('[Teaching] Stepper pos updated: $pos');
      }
      return;
    }

    // ── Data Parsing — Only record if we're in recording mode ───────────────
    if (!state.isRecording) return;

    // Try triple format: "encoder1,encoder2,stepper"
    final parts = cleanLine.split(',');
    if (parts.length >= 3) {
      final enc1 = int.tryParse(parts[0].trim());
      final enc2 = int.tryParse(parts[1].trim());
      final stepper = int.tryParse(parts[2].trim());
      if (enc1 != null && enc2 != null && stepper != null) {
        _addSample(enc1, enc2, stepper);
        return;
      }
    }

    // Try dual format: "encoder1,encoder2" (stepper defaults to 0)
    if (parts.length == 2) {
      final enc1 = int.tryParse(parts[0].trim());
      final enc2 = int.tryParse(parts[1].trim());
      if (enc1 != null && enc2 != null) {
        _addSample(enc1, enc2, 0);
        return;
      }
    }

    // Try "V:123" format (Arduino UNO single encoder)
    if (cleanLine.startsWith('V:')) {
      final valStr = cleanLine.substring(2);
      final val = int.tryParse(valStr);
      if (val != null) {
        _addSample(val, 0, 0);
        return;
      }
    }

    // Try single integer fallback
    final singleVal = int.tryParse(cleanLine);
    if (singleVal != null) {
      _addSample(singleVal, 0, 0);
      return;
    }

    debugPrint('[Teaching] Unrecognized line: $cleanLine');
  }

  void _addSample(int enc1, int enc2, int stepper) {
    latestEncoder1 = enc1;
    latestEncoder2 = enc2;
    latestStepperPos = stepper;

    final sample = MotionSample.fromTriple(
      _stopwatch.elapsedMilliseconds,
      enc1,
      enc2,
      stepper,
    );

    state = state.copyWith(
      samples: [...state.samples, sample],
      elapsedMs: _stopwatch.elapsedMilliseconds,
    );
  }

  void stopTeaching() {
    if (!state.isRecording) return;
    _dataSubscription?.cancel();
    _stopwatch.stop();
    _btNotifier.sendCommand('S');

    if (state.samples.isEmpty) {
      state = const TrajectoryRecordingState();
      return;
    }
    state = state.copyWith(status: RecordingStatus.saving);
  }

  void discardTeaching() {
    _dataSubscription?.cancel();
    _stopwatch.stop();
    _btNotifier.sendCommand('S');
    state = const TrajectoryRecordingState();
  }

  void saveAsRoutine(String name, {int? markerId}) {
    if (state.samples.isEmpty) return;

    final recording = MotionRecording(
      id: 'recording_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Untitled Recording' : name.trim(),
      samples: List.of(state.samples),
      createdAt: DateTime.now(),
      durationMs: state.elapsedMs,
    );

    // Convert to Routine to store in the existing motion library
    final routine = recording.toRoutine().copyWith(markerId: markerId);

    _ref.read(motionLibraryProvider.notifier).saveRoutine(routine);
    state = const TrajectoryRecordingState();
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
}
