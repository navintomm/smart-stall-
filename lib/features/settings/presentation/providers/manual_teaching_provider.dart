import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/trajectory_recording_state.dart';
import '../../domain/models/motion_sample.dart';
import '../../domain/models/motion_recording.dart';
import 'motion_library_provider.dart';
import '../../../connection/presentation/providers/bluetooth_provider.dart';
import '../../../connection/domain/services/bluetooth_service.dart';

final manualTeachingProvider =
    StateNotifierProvider<ManualTeachingNotifier, TrajectoryRecordingState>((ref) {
  final btService = ref.watch(bluetoothServiceProvider);
  return ManualTeachingNotifier(ref, btService);
});

class ManualTeachingNotifier extends StateNotifier<TrajectoryRecordingState> {
  final Ref _ref;
  final AppBluetoothService _bluetoothService;
  StreamSubscription<String>? _dataSubscription;
  final Stopwatch _stopwatch = Stopwatch();

  ManualTeachingNotifier(this._ref, this._bluetoothService)
      : super(const TrajectoryRecordingState());

  void startTeaching() {
    if (state.isRecording) return;
    
    // Clear state and start
    _stopwatch.reset();
    _stopwatch.start();
    state = const TrajectoryRecordingState(status: RecordingStatus.recording);

    // Send the start command to ESP32
    _bluetoothService.sendCommand('T');

    // Listen to incoming strings
    _dataSubscription?.cancel();
    _dataSubscription = _bluetoothService.incomingData.listen(_handleIncomingData);
  }

  void _handleIncomingData(String data) {
    if (!state.isRecording) return;

    final lines = data.split('\n');
    for (var line in lines) {
      final cleanLine = line.replaceAll('\r', '').replaceAll('\u0000', '').trim();
      if (cleanLine.isEmpty) continue;

      // Try to extract an integer value. The Arduino sends "V:123"
      final filtered = cleanLine.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (filtered.isNotEmpty) {
        final parsedValue = int.tryParse(filtered);
        if (parsedValue != null) {
          final sample = MotionSample(
            timestampMs: _stopwatch.elapsedMilliseconds,
            servo1Angle: parsedValue.toDouble(),
            servo2Angle: 0.0,
          );
          
          state = state.copyWith(
            samples: [...state.samples, sample],
            elapsedMs: _stopwatch.elapsedMilliseconds,
          );
        }
      }
    }
  }

  void stopTeaching() {
    if (!state.isRecording) return;
    _dataSubscription?.cancel();
    _stopwatch.stop();
    _bluetoothService.sendCommand('S');

    if (state.samples.isEmpty) {
      state = const TrajectoryRecordingState();
      return;
    }
    state = state.copyWith(status: RecordingStatus.saving);
  }

  void discardTeaching() {
    _dataSubscription?.cancel();
    _stopwatch.stop();
    _bluetoothService.sendCommand('S');
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
