import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../connection/presentation/providers/bluetooth_provider.dart';

class StepperJogState {
  final bool isJogging;
  final int? currentPosition;

  const StepperJogState({this.isJogging = false, this.currentPosition});

  StepperJogState copyWith({bool? isJogging, int? currentPosition}) {
    return StepperJogState(
      isJogging: isJogging ?? this.isJogging,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}

class StepperJogNotifier extends StateNotifier<StepperJogState> {
  final BluetoothStateNotifier _btNotifier;
  Timer? _jogTimer;
  StreamSubscription<String>? _dataSub;

  StepperJogNotifier(this._btNotifier) : super(const StepperJogState()) {
    // Listen for STEPPER_POS responses
    _dataSub = _btNotifier.incomingData.listen((line) {
      if (line.startsWith('STEPPER_POS,')) {
        final posStr = line.substring('STEPPER_POS,'.length);
        final pos = int.tryParse(posStr);
        if (pos != null) {
          state = state.copyWith(isJogging: false, currentPosition: pos);
        }
      }
    });
  }

  /// Start jogging the stepper UP (sends "UP" every 80ms while held).
  void startUp() {
    if (state.isJogging) return;
    state = state.copyWith(isJogging: true);
    _jogTimer?.cancel();
    _jogTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _btNotifier.sendCommand('UP');
    });
  }

  /// Start jogging the stepper DOWN (sends "DO" every 80ms while held).
  void startDown() {
    if (state.isJogging) return;
    state = state.copyWith(isJogging: true);
    _jogTimer?.cancel();
    _jogTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _btNotifier.sendCommand('DO');
    });
  }

  /// Stop jogging (sends "ST" once, waits for STEPPER_POS response).
  void stop() {
    _jogTimer?.cancel();
    _jogTimer = null;
    _btNotifier.sendCommand('ST');
    // isJogging will be set to false when STEPPER_POS is received
  }

  @override
  void dispose() {
    _jogTimer?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }
}

final stepperJogProvider =
    StateNotifierProvider<StepperJogNotifier, StepperJogState>((ref) {
  final btNotifier = ref.watch(bluetoothProvider.notifier);
  return StepperJogNotifier(btNotifier);
});
