import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../../domain/services/bluetooth_service.dart';

final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  return BluetoothService();
});

class BluetoothStateNotifier extends StateNotifier<AsyncValue<List<BluetoothDevice>>> {
  final BluetoothService _service;

  BluetoothStateNotifier(this._service) : super(const AsyncValue.loading()) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    state = const AsyncValue.loading();
    try {
      final devices = await _service.getBondedDevices();
      state = AsyncValue.data(devices);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> connect(String address) async {
    return await _service.connect(address);
  }

  void disconnect() {
    _service.disconnect();
    // trigger a rebuild or state update if necessary
    state = AsyncValue.data(state.value ?? []); 
  }
}

final bluetoothProvider = StateNotifierProvider<BluetoothStateNotifier, AsyncValue<List<BluetoothDevice>>>((ref) {
  final service = ref.watch(bluetoothServiceProvider);
  return BluetoothStateNotifier(service);
});
